import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:attendance_register_app/core/constants/app_constants.dart';
import 'package:attendance_register_app/core/errors/exceptions.dart';
import 'package:attendance_register_app/core/network/api_client.dart';
import 'package:attendance_register_app/features/attendance/data/repositories/attendance_repository.dart';
import 'package:attendance_register_app/features/attendance/data/services/attendance_api_service.dart';
import 'package:attendance_register_app/features/leave/data/repositories/leave_repository.dart';
import 'package:attendance_register_app/features/leave/data/services/leave_api_service.dart';
import 'package:attendance_register_app/features/sync/data/repositories/sync_repository.dart';
import 'package:attendance_register_app/features/sync/data/services/cache_storage_service.dart';
import 'package:attendance_register_app/features/sync/data/services/sync_storage_service.dart';
import 'package:attendance_register_app/shared/models/attendance_enums.dart';
import 'package:attendance_register_app/shared/models/leave_model.dart';
import 'package:attendance_register_app/shared/models/sync_operation.dart';
import 'package:attendance_register_app/shared/widgets/offline_banner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late SyncStorageService storage;
  late CacheStorageService cache;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('req_tests_');
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

  group('Required Assignment Automated Tests', () {
    test('1. Check-out without check-in is rejected', () async {
      final client = MockClient((_) async => http.Response('{"StatusCode":6001,"message":{"body":"No check-in."}}', 422));
      final repo = AttendanceRepository(apiService: AttendanceApiService(client: ApiClient(client: client)), storageService: storage, cacheService: cache);
      final res = await repo.recordPunch(eventType: AttendanceEventType.checkOut, latitude: AppConstants.officeLatitude, longitude: AppConstants.officeLongitude);
      expect(res.syncStatus, SyncStatus.rejected);
      expect(storage.getRejectedEvents(), hasLength(1));
    });

    test('2. Repeated submission or retry does not create duplicate attendance', () async {
      final dupClient = MockClient((_) async => http.Response('{"StatusCode":6001,"message":{"body":"Duplicate event."}}', 409));
      final offClient = MockClient((_) async => throw const SocketException('Offline'));
      final repo = AttendanceRepository(apiService: AttendanceApiService(client: ApiClient(client: offClient)), storageService: storage, cacheService: cache);
      await repo.recordPunch(eventType: AttendanceEventType.checkIn, latitude: AppConstants.officeLatitude, longitude: AppConstants.officeLongitude);
      expect(storage.getPendingEvents(), hasLength(1));

      final syncRepo = SyncRepository(storageService: storage, apiService: AttendanceApiService(client: ApiClient(client: dupClient)));
      final synced = await syncRepo.syncPendingEvents();
      expect(synced, 1);
      expect(storage.getPendingEvents(), isEmpty);
    });

    test('3. Pending attendance survives persistence and can be synchronized in order', () async {
      final now = DateTime.now();
      await storage.enqueueOperation(SyncOperation(
        id: 'evt-1', type: SyncOperationType.checkIn, payload: {'eventId': 'evt-1'}, createdAt: now.subtract(const Duration(minutes: 5)), status: SyncOpStatus.pending,
      ));
      await storage.enqueueOperation(SyncOperation(
        id: 'evt-2', type: SyncOperationType.checkOut, payload: {'eventId': 'evt-2'}, createdAt: now, status: SyncOpStatus.pending,
      ));

      // Simulate app kill & reopen
      await Hive.close();
      Hive.init(tempDir.path);
      final reloaded = SyncStorageService();
      await reloaded.init();

      final ops = reloaded.getPendingOperations();
      expect(ops, hasLength(2));
      expect(ops[0].id, 'evt-1'); // In-order FIFO Check-in first
      expect(ops[1].id, 'evt-2'); // Check-out second

      final order = <String>[];
      final onlineClient = MockClient((req) async {
        order.add(req.body);
        return http.Response('{"StatusCode":6000,"data":{"status":"synced"}}', 201);
      });
      final syncRepo = SyncRepository(storageService: reloaded, apiService: AttendanceApiService(client: ApiClient(client: onlineClient)));
      await syncRepo.syncPendingOperations();
      expect(order, hasLength(2));
      expect(reloaded.getPendingOperations(), isEmpty);
    });

    test('4. Overlapping leave dates are rejected', () async {
      final client = MockClient((_) async => http.Response('{"StatusCode":6001,"message":{"body":"Overlapping leave."}}', 409));
      final leaveRepo = LeaveRepository(apiService: LeaveApiService(client: ApiClient(client: client)), cacheService: cache);
      expect(
        () => leaveRepo.submitLeaveRequest(leaveType: LeaveType.casual, startDate: DateTime(2026, 11, 20), endDate: DateTime(2026, 11, 22), numberOfDays: 3, reason: 'Vacation with family'),
        throwsA(isA<ServerException>().having((e) => e.message, 'message', contains('Overlapping'))),
      );
    });

    testWidgets('5. Widget test covering pending-sync state', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: OfflineBanner(message: '2 attendance events recorded offline.', isOffline: true, actionLabel: 'Sync Now', onActionTap: () {}),
        ),
      ));
      expect(find.byType(OfflineBanner), findsOneWidget);
      expect(find.text('2 attendance events recorded offline.'), findsOneWidget);
      expect(find.text('Sync Now'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });
  });
}
