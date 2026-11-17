import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:attendance_register_app/core/network/api_client.dart';
import 'package:attendance_register_app/features/attendance/data/services/attendance_api_service.dart';
import 'package:attendance_register_app/features/sync/bloc/sync_bloc.dart';
import 'package:attendance_register_app/features/sync/bloc/sync_event.dart';
import 'package:attendance_register_app/features/sync/bloc/sync_state.dart';
import 'package:attendance_register_app/features/sync/data/repositories/sync_repository.dart';
import 'package:attendance_register_app/features/sync/data/services/sync_storage_service.dart';
import 'package:attendance_register_app/shared/models/sync_operation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late SyncStorageService storage;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('sync_recovery_test_');
    Hive.init(tempDir.path);
    storage = SyncStorageService();
    await storage.init();
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('Sync Queue Recovery & Auto-Sync Tests (TEST C, D, E)', () {
    test('TEST C & D: Reconnection triggers auto-sync; moves Pending to Synced',
        () async {
      await storage.enqueueOperation(SyncOperation(
        id: 'op-auto-1',
        type: SyncOperationType.checkIn,
        payload: {
          'eventId': 'op-auto-1',
          'eventType': 'check_in',
          'timestamp': DateTime.now().toIso8601String(),
        },
        createdAt: DateTime.now(),
      ));
      expect(storage.getPendingOperations().length, 1);

      final onlineClient = MockClient((request) async {
        if (request.url.path.contains('/health')) {
          return http.Response('{"status":"ok"}', 200);
        }
        return http.Response(
          '{"StatusCode":6000,"message":"Synced","data":{"status":"synced"}}',
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final syncRepo = SyncRepository(
        storageService: storage,
        attendanceApiService: AttendanceApiService(
          client: ApiClient(client: onlineClient),
        ),
        apiClient: ApiClient(client: onlineClient),
      );

      final bloc = SyncBloc(repository: syncRepo, enableAutoSync: false);
      bloc.add(const AutoSyncIfOnline());

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<SyncState>((s) =>
            s is SyncLoaded &&
            s.pendingOperations.isEmpty &&
            s.syncedOperations.any((o) => o.id == 'op-auto-1'))),
      );
      expect(storage.getPendingOperations().length, 0);
      expect(storage.getSyncedOperations().length, 1);
      await bloc.close();
    });

    test('TEST E: Rejected operation remains failed for retry while others sync',
        () async {
      await storage.enqueueOperation(SyncOperation(
        id: 'op-bad-1',
        type: SyncOperationType.checkIn,
        payload: {'eventId': 'op-bad-1', 'eventType': 'check_in'},
        createdAt: DateTime(2026, 11, 1),
      ));
      await storage.enqueueOperation(SyncOperation(
        id: 'op-good-2',
        type: SyncOperationType.checkOut,
        payload: {'eventId': 'op-good-2', 'eventType': 'check_out'},
        createdAt: DateTime(2026, 11, 2),
      ));

      final selectiveClient = MockClient((req) async {
        if (req.body.contains('op-bad-1')) {
          return http.Response(
            '{"StatusCode":6001,"message":{"title":"Error","body":"Invalid perimeter"},"data":{"status":"rejected","rejectionReason":"Outside geofence"}}',
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(
          '{"StatusCode":6000,"message":"Synced","data":{"status":"synced"}}',
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final syncRepo = SyncRepository(
        storageService: storage,
        attendanceApiService: AttendanceApiService(
          client: ApiClient(client: selectiveClient),
        ),
      );

      final synced = await syncRepo.syncPendingOperations();
      expect(synced, 1);
      final failed = storage.getFailedOperations();
      expect(failed.length, 1);
      expect(failed.first.id, 'op-bad-1');
      expect(failed.first.errorMessage, 'Outside geofence');
      expect(storage.getSyncedOperations().any((o) => o.id == 'op-good-2'),
          isTrue);
    });
  });
}

