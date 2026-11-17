import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:attendance_register_app/core/network/api_client.dart';
import 'package:attendance_register_app/features/attendance/data/repositories/attendance_repository.dart';
import 'package:attendance_register_app/features/attendance/data/services/attendance_api_service.dart';
import 'package:attendance_register_app/features/sync/data/repositories/sync_repository.dart';
import 'package:attendance_register_app/features/sync/data/services/cache_storage_service.dart';
import 'package:attendance_register_app/features/sync/data/services/sync_storage_service.dart';
import 'package:attendance_register_app/shared/models/attendance_enums.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late SyncStorageService storage;
  late CacheStorageService cache;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_idempotency_test_');
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

  group('Sync Reconnect, Queue Draining & Idempotency Tests', () {
    test('1. Reconnecting internet synchronizes pending queue', () async {
      final offlineClient = MockClient((request) async {
        throw const SocketException('Offline');
      });

      final repo = AttendanceRepository(
        apiService: AttendanceApiService(
          client: ApiClient(client: offlineClient),
        ),
        storageService: storage,
        cacheService: cache,
      );

      // Punch while offline
      await repo.recordPunch(
        eventType: AttendanceEventType.checkIn,
        latitude: 12.971598,
        longitude: 77.594562,
        distanceMeters: 45.0,
      );
      expect(storage.getPendingEvents().length, 1);

      // Reconnect internet: online client responds 201
      final onlineClient = MockClient((request) async {
        return http.Response(
          '{"StatusCode":6000,"message":{"title":"Success","body":"Synced"},"data":{"status":"synced"}}',
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final syncRepo = SyncRepository(
        storageService: storage,
        apiService: AttendanceApiService(
          client: ApiClient(client: onlineClient),
        ),
      );

      final syncedCount = await syncRepo.syncPendingEvents();
      expect(syncedCount, 1);
      expect(storage.getPendingEvents().length, 0);
    });

    test('2. Duplicate submission prevention & idempotency handling', () async {
      final duplicateClient = MockClient((request) async {
        return http.Response(
          '{"StatusCode":6001,"message":{"title":"Conflict","body":"Duplicate event detected."},"data":null}',
          409,
          headers: {'content-type': 'application/json'},
        );
      });

      final offlineClient = MockClient((request) async {
        throw const SocketException('Offline');
      });

      final repo = AttendanceRepository(
        apiService: AttendanceApiService(
          client: ApiClient(client: offlineClient),
        ),
        storageService: storage,
        cacheService: cache,
      );

      // Punch offline
      await repo.recordPunch(
        eventType: AttendanceEventType.checkIn,
        latitude: 12.971598,
        longitude: 77.594562,
        distanceMeters: 45.0,
      );

      final syncRepo = SyncRepository(
        storageService: storage,
        apiService: AttendanceApiService(
          client: ApiClient(client: duplicateClient),
        ),
      );

      // Sync recognizes duplicate key on server and safely marks synced locally
      final syncedCount = await syncRepo.syncPendingEvents();
      expect(syncedCount, 1);
      expect(storage.getPendingEvents().length, 0);
    });
  });
}

