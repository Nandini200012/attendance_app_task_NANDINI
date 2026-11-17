import 'package:uuid/uuid.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/models/leave_model.dart';
import '../../../../shared/models/sync_operation.dart';
import '../../../sync/data/services/cache_storage_service.dart';
import '../../../sync/data/services/sync_storage_service.dart';
import '../services/leave_api_service.dart';

/// Repository managing leave balance queries and offline-first leave submissions.
class LeaveRepository {
  final LeaveApiService _apiService;
  final CacheStorageService _cacheService;
  final SyncStorageService _storageService;
  final Uuid _uuid;

  LeaveRepository({
    LeaveApiService? apiService,
    CacheStorageService? cacheService,
    SyncStorageService? storageService,
    Uuid? uuid,
  }) : _apiService = apiService ?? LeaveApiService(),
       _cacheService = cacheService ?? CacheStorageService(),
       _storageService = storageService ?? SyncStorageService(),
       _uuid = uuid ?? const Uuid();

  Future<LeaveBalance> getLeaveBalance() async {
    try {
      final balance = await _apiService.getLeaveBalance();
      await _cacheService.cacheLeaveBalance(balance);
      return balance;
    } catch (_) {
      return _cacheService.getCachedLeaveBalance() ?? LeaveBalance.empty;
    }
  }

  Future<List<LeaveRequest>> getLeaveRequests() async {
    try {
      final requests = await _apiService.getLeaveRequests();
      await _cacheService.cacheLeaveRequests(requests);
      return requests;
    } catch (_) {
      return _cacheService.getCachedLeaveRequests();
    }
  }

  Future<LeaveRequest> submitLeaveRequest({
    required LeaveType leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required int numberOfDays,
    required String reason,
  }) async {
    final opId = 'lev-${_uuid.v4()}';
    final typeStr = leaveType == LeaveType.sick ? 'sick' : 'casual';
    final sDate = startDate.toIso8601String().substring(0, 10);
    final eDate = endDate.toIso8601String().substring(0, 10);

    final payload = {
      'request_id': opId,
      'leave_type': typeStr,
      'leaveType': typeStr,
      'start_date': sDate,
      'startDate': sDate,
      'end_date': eDate,
      'endDate': eDate,
      'number_of_days': numberOfDays,
      'numberOfDays': numberOfDays,
      'reason': reason,
      'applied_date': DateTime.now().toIso8601String().substring(0, 10),
    };

    final op = SyncOperation(
      id: opId,
      type: SyncOperationType.leaveApplication,
      payload: payload,
      createdAt: DateTime.now(),
      status: SyncOpStatus.pending,
    );
    await _storageService.enqueueOperation(op);

    try {
      final created = await _apiService.submitLeaveRequest(
        leaveType: leaveType,
        startDate: startDate,
        endDate: endDate,
        numberOfDays: numberOfDays,
        reason: reason,
      );
      await _storageService.updateOperationStatus(opId, SyncOpStatus.synced);
      final cached = _cacheService.getCachedLeaveRequests();
      await _cacheService.cacheLeaveRequests([created, ...cached]);
      return created;
    } on ServerException catch (e) {
      await _storageService.updateOperationStatus(
        opId,
        SyncOpStatus.failed,
        errorMessage: e.message,
        incrementRetry: true,
      );
      rethrow;
    } catch (_) {
      final offlineRequest = LeaveRequest(
        id: opId,
        leaveType: leaveType,
        startDate: startDate,
        endDate: endDate,
        requestedDays: numberOfDays,
        reason: reason,
        status: LeaveStatus.pending,
        submissionDate: DateTime.now(),
      );
      final cached = _cacheService.getCachedLeaveRequests();
      await _cacheService.cacheLeaveRequests([offlineRequest, ...cached]);
      return offlineRequest;
    }
  }
}
