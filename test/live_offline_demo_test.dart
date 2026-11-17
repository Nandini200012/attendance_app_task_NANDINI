// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:attendance_register_app/core/constants/app_constants.dart';
import 'package:attendance_register_app/core/network/api_client.dart';
import 'package:attendance_register_app/features/attendance/data/repositories/attendance_repository.dart';
import 'package:attendance_register_app/features/attendance/data/services/attendance_api_service.dart';
import 'package:attendance_register_app/features/dashboard/data/services/employee_api_service.dart';
import 'package:attendance_register_app/features/sync/data/repositories/sync_repository.dart';
import 'package:attendance_register_app/features/sync/data/services/cache_storage_service.dart';
import 'package:attendance_register_app/features/sync/data/services/sync_storage_service.dart';
import 'package:attendance_register_app/shared/models/attendance_enums.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final storageDir = Directory('.live_demo_storage');
  late SyncStorageService syncStorage;
  late CacheStorageService cacheStorage;
  String? capturedEventId;

  setUpAll(() async {
    HttpOverrides.global = null;
    if (storageDir.existsSync()) storageDir.deleteSync(recursive: true);
    storageDir.createSync(recursive: true);
    Hive.init(storageDir.path);
    syncStorage = SyncStorageService();
    await syncStorage.init();
    cacheStorage = CacheStorageService();
    await cacheStorage.init();
  });

  setUp(() {
    HttpOverrides.global = null;
  });

  tearDownAll(() async {
    await Hive.close();
  });

  test('Step 1 & 2: Launch App Online & Load/Cache Data', () async {
    final client = ApiClient(baseUrl: 'http://localhost:3000');
    final isOnline = await client.checkConnectivity();
    expect(isOnline, isTrue);

    final empService = EmployeeApiService(client: client);
    final profile = await empService.getEmployeeProfile();
    await cacheStorage.cacheEmployee(profile);

    expect(profile.employeeCode, 'EMP-2048');
    final cached = cacheStorage.getCachedEmployee();
    expect(cached?.name, profile.name);
    print('[DEMO 1&2] Fetched & cached profile in Hive: ${cached?.name}');
  });

  test('Step 3, 4 & 5: Turn OFF Internet & Record Offline Punch', () async {
    // Simulate offline network by using unreachable port
    final offlineClient = ApiClient(baseUrl: 'http://127.0.0.1:39999');
    final repo = AttendanceRepository(
      storageService: syncStorage,
      cacheService: cacheStorage,
      apiService: AttendanceApiService(client: offlineClient),
    );

    final punchDate = DateTime(2028, 1, 1).add(
      Duration(days: DateTime.now().microsecondsSinceEpoch % 5000),
    );
    final event = await repo.recordPunch(
      eventType: AttendanceEventType.checkIn,
      latitude: AppConstants.officeLatitude,
      longitude: AppConstants.officeLongitude,
      distanceMeters: 38.5,
      timestamp: punchDate,
    );

    capturedEventId = event.eventId;
    expect(capturedEventId!.startsWith('evt-'), isTrue);
    expect(event.syncStatus, SyncStatus.pending);

    final pending = syncStorage.getPendingEvents();
    expect(pending.length, 1);
    expect(pending.first.eventId, capturedEventId);
    print('[DEMO 3,4,5] Offline Punch created: $capturedEventId (Pending)');
  });

  test('Step 6 & 7: Restart Simulation & Verify Persistence', () async {
    // Terminate app session and close Hive boxes
    await Hive.close();

    // Reopen app from disk storage directory
    Hive.init(storageDir.path);
    final restartedStorage = SyncStorageService();
    await restartedStorage.init();

    final preservedPending = restartedStorage.getPendingEvents();
    expect(preservedPending.length, 1);
    expect(preservedPending.first.eventId, capturedEventId);
    print('[DEMO 6&7] App restarted from disk. Event preserved: $capturedEventId');
  });

  test('Step 8 & 9: Turn Internet ON & Sync to Real Mock API', () async {
    final restartedStorage = SyncStorageService();
    await restartedStorage.init();
    final liveClient = ApiClient(baseUrl: 'http://localhost:3000');
    final isOnline = await liveClient.checkConnectivity();
    expect(isOnline, isTrue);

    final liveAttendanceApi = AttendanceApiService(client: liveClient);
    final syncRepo = SyncRepository(
      storageService: restartedStorage,
      apiService: liveAttendanceApi,
    );

    final syncedCount = await syncRepo.syncPendingEvents();
    expect(syncedCount, 1);
    expect(restartedStorage.getPendingEvents().length, 0);

    final syncedEvents = restartedStorage.getSyncedEvents();
    expect(syncedEvents.any((e) => e.eventId == capturedEventId), isTrue);
    print('[DEMO 8&9] Event $capturedEventId synced successfully to Mock API!');
  });

  test('Step 10: Confirm Duplicate Events Are Not Created (Idempotency)', () async {
    final restartedStorage = SyncStorageService();
    await restartedStorage.init();
    final syncedEvent = restartedStorage.getSyncedEvents().firstWhere(
      (e) => e.eventId == capturedEventId,
    );

    // Re-queue already synced event to simulate network retry duplicate
    await restartedStorage.queuePendingEvent(syncedEvent);
    expect(restartedStorage.getPendingEvents().length, 1);

    final liveClient = ApiClient(baseUrl: 'http://localhost:3000');
    final liveAttendanceApi = AttendanceApiService(client: liveClient);
    final syncRepo = SyncRepository(
      storageService: restartedStorage,
      apiService: liveAttendanceApi,
    );

    // Draining again hits server; server returns 409 Conflict.
    final count = await syncRepo.syncPendingEvents();
    expect(count, 1); // 409 is recognized as idempotent success
    expect(restartedStorage.getPendingEvents().length, 0);
    print('[DEMO 10] Server 409 handled cleanly. No duplicate created.');
  });
}
