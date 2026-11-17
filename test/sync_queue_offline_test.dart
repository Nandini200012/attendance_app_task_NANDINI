import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/testing.dart';
import 'package:attendance_register_app/core/network/api_client.dart';
import 'package:attendance_register_app/features/attendance/data/repositories/attendance_repository.dart';
import 'package:attendance_register_app/features/attendance/data/services/attendance_api_service.dart';
import 'package:attendance_register_app/features/leave/data/repositories/leave_repository.dart';
import 'package:attendance_register_app/features/leave/data/services/leave_api_service.dart';
import 'package:attendance_register_app/features/sync/data/services/cache_storage_service.dart';
import 'package:attendance_register_app/features/sync/data/services/sync_storage_service.dart';
import 'package:attendance_register_app/shared/models/attendance_enums.dart';
import 'package:attendance_register_app/shared/models/leave_enums.dart';
import 'package:attendance_register_app/shared/models/sync_operation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late SyncStorageService storage;
  late CacheStorageService cache;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('sync_offline_test_');
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

  group('Sync Queue Offline Tests (TEST A, B, F)', () {
    test('TEST A: Offline Check-in and Check-out appear in Sync Management',
        () async {
      final offlineClient =
          MockClient((_) async => throw const SocketException('Offline'));
      final attRepo = AttendanceRepository(
        apiService:
            AttendanceApiService(client: ApiClient(client: offlineClient)),
        storageService: storage,
        cacheService: cache,
      );

      final inEvt = await attRepo.recordPunch(
        eventType: AttendanceEventType.checkIn,
        latitude: 10.6940374,
        longitude: 76.7345539,
        distanceMeters: 0.0,
      );
      final outEvt = await attRepo.recordPunch(
        eventType: AttendanceEventType.checkOut,
        latitude: 10.6940374,
        longitude: 76.7345539,
        distanceMeters: 0.0,
      );

      final pending = storage.getPendingOperations();
      expect(pending.length, 2);
      expect(pending.any((o) => o.id == inEvt.eventId), isTrue);
      expect(pending.any((o) => o.id == outEvt.eventId), isTrue);
    });

    test('TEST B: Offline Leave Application appears in Sync Management',
        () async {
      final offlineClient =
          MockClient((_) async => throw const SocketException('Offline'));
      final leaveRepo = LeaveRepository(
        apiService: LeaveApiService(client: ApiClient(client: offlineClient)),
        storageService: storage,
        cacheService: cache,
      );

      final req = await leaveRepo.submitLeaveRequest(
        leaveType: LeaveType.casual,
        startDate: DateTime(2026, 11, 20),
        endDate: DateTime(2026, 11, 21),
        numberOfDays: 2,
        reason: 'Family event attendance offline',
      );

      final pending = storage.getPendingOperations();
      expect(pending.any((o) => o.id == req.id), isTrue);
      expect(
        pending.firstWhere((o) => o.id == req.id).type,
        SyncOperationType.leaveApplication,
      );
    });

    test('TEST F: App restart preserves pending queue records', () async {
      await storage.enqueueOperation(SyncOperation(
        id: 'op-persist-1',
        type: SyncOperationType.checkIn,
        payload: {'name': 'test'},
        createdAt: DateTime.now(),
      ));

      final restartedStorage = SyncStorageService();
      await restartedStorage.init();
      final preserved = restartedStorage.getPendingOperations();

      expect(preserved.length, 1);
      expect(preserved.first.id, 'op-persist-1');
    });
  });
}

