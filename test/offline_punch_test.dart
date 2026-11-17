import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:attendance_register_app/core/constants/app_constants.dart';
import 'package:attendance_register_app/core/network/api_client.dart';
import 'package:attendance_register_app/features/attendance/data/repositories/attendance_repository.dart';
import 'package:attendance_register_app/features/attendance/data/services/attendance_api_service.dart';
import 'package:attendance_register_app/features/sync/data/services/cache_storage_service.dart';
import 'package:attendance_register_app/features/sync/data/services/sync_storage_service.dart';
import 'package:attendance_register_app/shared/models/attendance_enums.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late SyncStorageService storage;
  late CacheStorageService cache;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_punch_test_');
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

  group('Offline Punch & Restart Persistence Tests', () {
    test('1. Check-in while online succeeds and marks synced', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          '{"StatusCode":6000,"message":{"title":"Success","body":"Synced"},"data":{"event_id":"evt-1","status":"synced"}}',
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = AttendanceRepository(
        apiService: AttendanceApiService(client: ApiClient(client: mockClient)),
        storageService: storage,
        cacheService: cache,
      );

      final result = await repo.recordPunch(
        eventType: AttendanceEventType.checkIn,
        latitude: AppConstants.officeLatitude,
        longitude: AppConstants.officeLongitude,
      );

      expect(result.syncStatus, SyncStatus.synced);
      expect(storage.getPendingEvents().length, 0);
      expect(storage.getSyncedEvents().length, greaterThanOrEqualTo(1));
    });

    test('2. Check-in while offline queues locally with unique ID', () async {
      final offlineClient = MockClient((request) async {
        throw const SocketException('No internet');
      });

      final repo = AttendanceRepository(
        apiService:
            AttendanceApiService(client: ApiClient(client: offlineClient)),
        storageService: storage,
        cacheService: cache,
      );

      final event = await repo.recordPunch(
        eventType: AttendanceEventType.checkIn,
        latitude: AppConstants.officeLatitude,
        longitude: AppConstants.officeLongitude,
      );

      expect(event.syncStatus, SyncStatus.pending);
      expect(event.eventId.startsWith('evt-'), isTrue);
      expect(storage.getPendingEvents().length, 1);
      expect(storage.getPendingEvents().first.eventId, event.eventId);
    });

    test('3. Pending events survive app restart simulation', () async {
      final offlineClient = MockClient((request) async {
        throw const SocketException('Offline');
      });

      final repo = AttendanceRepository(
        apiService:
            AttendanceApiService(client: ApiClient(client: offlineClient)),
        storageService: storage,
        cacheService: cache,
      );

      final event = await repo.recordPunch(
        eventType: AttendanceEventType.checkIn,
        latitude: AppConstants.officeLatitude,
        longitude: AppConstants.officeLongitude,
      );

      final restartedStorage = SyncStorageService();
      await restartedStorage.init();

      final preservedEvents = restartedStorage.getPendingEvents();
      expect(preservedEvents.length, 1);
      expect(preservedEvents.first.eventId, event.eventId);
    });

    test('4. Offline punch outside configured radius is rejected locally',
        () async {
      final repo = AttendanceRepository(
        apiService: null,
        storageService: storage,
        cacheService: cache,
      );

      // Punch from ~5.5km away from the configured office coordinates
      final event = await repo.recordPunch(
        eventType: AttendanceEventType.checkIn,
        latitude: AppConstants.officeLatitude + 0.05,
        longitude: AppConstants.officeLongitude + 0.05,
      );

      expect(event.syncStatus, SyncStatus.rejected);
      expect(
          event.rejectionReason, contains('Outside allowed geofence perimeter'));
      expect(storage.getRejectedEvents().length, 1);
      expect(storage.getPendingEvents().length, 0);
    });
  });
}
