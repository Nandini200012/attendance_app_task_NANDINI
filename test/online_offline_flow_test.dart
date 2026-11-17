import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:attendance_register_app/core/errors/exceptions.dart';
import 'package:attendance_register_app/core/network/api_client.dart';
import 'package:attendance_register_app/features/attendance/data/repositories/attendance_repository.dart';
import 'package:attendance_register_app/features/attendance/data/services/attendance_api_service.dart';
import 'package:attendance_register_app/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:attendance_register_app/features/dashboard/data/services/employee_api_service.dart';
import 'package:attendance_register_app/features/leave/data/repositories/leave_repository.dart';
import 'package:attendance_register_app/features/leave/data/services/leave_api_service.dart';
import 'package:attendance_register_app/features/sync/data/repositories/sync_repository.dart';
import 'package:attendance_register_app/features/sync/data/services/cache_storage_service.dart';
import 'package:attendance_register_app/features/sync/data/services/sync_storage_service.dart';
import 'package:attendance_register_app/shared/models/attendance_enums.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late SyncStorageService storage;
  late CacheStorageService cache;

  const empJson = '{"StatusCode":6000,"data":{"id":"emp-001","employee_id":"EMP-2048","employee_name":"Nandini N","designation":"Senior Flutter Specialist","department":"Mobile Engineering","email":"nandini.n@rebs.io"}}';
  const attJson = '{"StatusCode":6000,"data":[{"id":"REC-01","attendance_date":"2026-11-17","check_in_time":"09:15:00","attendance_status":"Present"}]}';
  const lveJson = '{"StatusCode":6000,"data":{"total_leave":22,"available_leave":7,"leave_type_breakdown":{"casual":{"total":12,"available":2},"sick":{"total":10,"available":5}}}}';

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('online_offline_test_');
    Hive.init(tempDir.path);
    storage = SyncStorageService();
    await storage.init();
    cache = CacheStorageService();
    await cache.init();
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  DashboardRepository makeDashRepo(http.Client client) => DashboardRepository(
    employeeService: EmployeeApiService(client: ApiClient(client: client)),
    attendanceService: AttendanceApiService(client: ApiClient(client: client)),
    leaveService: LeaveApiService(client: ApiClient(client: client)),
    storageService: storage,
    cacheService: cache,
  );

  group('Online and Offline Data Handling Flow', () {
    test('TEST 1: API connected - fetches actual API data and caches it', () async {
      final onlineClient = MockClient((req) async {
        if (req.url.path.contains('employee')) return http.Response(empJson, 200);
        if (req.url.path.contains('attendance')) return http.Response(attJson, 200);
        if (req.url.path.contains('leave/balance')) return http.Response(lveJson, 200);
        return http.Response('{"StatusCode":6000,"data":[]}', 200);
      });

      final data = await makeDashRepo(onlineClient).getDashboardData();
      expect(data.employee.name, 'Nandini N');
      expect(data.isOffline, isFalse);
      expect(cache.getCachedEmployee()?.name, 'Nandini N');
      expect(cache.getCachedLeaveBalance()?.totalAllocated, 22);
    });

    test('TEST 2: API disconnected - loads from cache and saves punch locally', () async {
      final onlineClient = MockClient((req) async => http.Response(empJson, 200));
      final emp = await EmployeeApiService(client: ApiClient(client: onlineClient)).getEmployeeProfile();
      await cache.cacheEmployee(emp);

      final offlineClient = MockClient((req) async => throw const SocketException('Offline'));
      final data = await makeDashRepo(offlineClient).getDashboardData();
      expect(data.isOffline, isTrue);
      expect(data.employee.name, 'Nandini N');

      final attRepo = AttendanceRepository(
        apiService: AttendanceApiService(client: ApiClient(client: offlineClient)),
        storageService: storage,
        cacheService: cache,
      );
      final punch = await attRepo.recordPunch(
        eventType: AttendanceEventType.checkIn,
        latitude: 12.971598,
        longitude: 77.594562,
        distanceMeters: 45.0,
      );
      expect(punch.syncStatus, SyncStatus.pending);
      expect(storage.getPendingEvents().length, 1);
    });

    test('TEST 3: API reconnected - pending attendance synchronizes', () async {
      final offlineClient = MockClient((req) async => throw const SocketException('Offline'));
      final attRepo = AttendanceRepository(
        apiService: AttendanceApiService(client: ApiClient(client: offlineClient)),
        storageService: storage,
        cacheService: cache,
      );
      await attRepo.recordPunch(
        eventType: AttendanceEventType.checkIn,
        latitude: 12.971598,
        longitude: 77.594562,
        distanceMeters: 45.0,
      );

      final onlineClient = MockClient((req) async => http.Response(
        '{"StatusCode":6000,"data":{"status":"synced"}}',
        201,
      ));
      final syncRepo = SyncRepository(
        apiService: AttendanceApiService(client: ApiClient(client: onlineClient)),
        storageService: storage,
      );

      final syncedCount = await syncRepo.syncPendingEvents();
      expect(syncedCount, 1);
      expect(storage.getPendingEvents(), isEmpty);
      expect(storage.getSyncedEvents().length, 1);
    });

    test('TEST 4: No cached data - throws NetworkException and shows empty state', () async {
      await cache.clearAllCache();
      await storage.clearAllSyncData();

      final offlineClient = MockClient((req) async => throw const SocketException('Offline'));
      expect(() => makeDashRepo(offlineClient).getDashboardData(), throwsA(isA<NetworkException>()));

      final leaveRepo = LeaveRepository(
        apiService: LeaveApiService(client: ApiClient(client: offlineClient)),
        storageService: storage,
        cacheService: cache,
      );
      final balance = await leaveRepo.getLeaveBalance();
      expect(balance.totalAllocated, 0);

      final requests = await leaveRepo.getLeaveRequests();
      expect(requests, isEmpty);
    });
  });
}
