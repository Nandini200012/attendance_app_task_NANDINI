import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:attendance_register_app/core/network/api_client.dart';
import 'package:attendance_register_app/features/attendance/bloc/attendance_bloc.dart';
import 'package:attendance_register_app/features/attendance/bloc/attendance_event.dart';
import 'package:attendance_register_app/features/attendance/bloc/attendance_state.dart';
import 'package:attendance_register_app/features/attendance/data/repositories/attendance_repository.dart';
import 'package:attendance_register_app/features/attendance/data/services/attendance_api_service.dart';
import 'package:attendance_register_app/features/attendance/presentation/widgets/today_attendance_card.dart';
import 'package:attendance_register_app/features/sync/data/services/cache_storage_service.dart';
import 'package:attendance_register_app/features/sync/data/services/sync_storage_service.dart';
import 'package:attendance_register_app/shared/models/attendance_enums.dart';
import 'package:attendance_register_app/shared/widgets/primary_button.dart';
import 'package:attendance_register_app/shared/widgets/secondary_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late SyncStorageService storage;
  late CacheStorageService cache;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('att_hist_test_');
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

  group('Check In Button State & History Appearance', () {
    testWidgets('1. Once checked in, check in button is disabled', (tester) async {
      Widget buildCard(AttendanceStatus status) => MaterialApp(
        home: Scaffold(
          body: TodayAttendanceCard(
            status: status,
            checkInTime: '09:00 AM',
            checkOutTime: '--:--',
            workingDuration: '1h 00m',
            onCheckIn: () {},
            onCheckOut: () {},
            isWithinRadius: true,
          ),
        ),
      );

      // Not checked in -> Check In enabled, Check Out disabled
      await tester.pumpWidget(buildCard(AttendanceStatus.notCheckedIn));
      PrimaryButton btnIn = tester.widget(find.byType(PrimaryButton));
      SecondaryButton btnOut = tester.widget(find.byType(SecondaryButton));
      expect(btnIn.onPressed, isNotNull);
      expect(btnOut.onPressed, isNull);

      // Once checked in -> Check In DISABLED, Check Out ENABLED
      await tester.pumpWidget(buildCard(AttendanceStatus.checkedIn));
      btnIn = tester.widget(find.byType(PrimaryButton));
      btnOut = tester.widget(find.byType(SecondaryButton));
      expect(btnIn.onPressed, isNull, reason: 'Check In button must be disabled once checked in');
      expect(btnOut.onPressed, isNotNull);

      // Checked out -> Check In ENABLED (can check in again!), Check Out DISABLED
      await tester.pumpWidget(buildCard(AttendanceStatus.checkedOut));
      btnIn = tester.widget(find.byType(PrimaryButton));
      btnOut = tester.widget(find.byType(SecondaryButton));
      expect(btnIn.onPressed, isNotNull, reason: 'Must allow checking in again after check out');
      expect(btnOut.onPressed, isNull);
    });

    test('2. Check in and check out submitted appear in attendance history', () async {
      final client = MockClient((req) async => http.Response(
        '{"StatusCode":6000,"data":{"status":"synced"}}',
        201,
      ));
      final repo = AttendanceRepository(
        apiService: AttendanceApiService(client: ApiClient(client: client)),
        storageService: storage,
        cacheService: cache,
      );

      final bloc = AttendanceBloc(repository: repo);

      // 1. Submit check-in
      bloc.add(const RecordPunch(
        eventType: AttendanceEventType.checkIn,
        latitude: 12.971598, longitude: 77.594562, distanceMeters: 45.0,
      ));

      await expectLater(
        bloc.stream,
        emits(predicate<AttendanceState>((s) =>
            s is AttendanceLoaded &&
            s.todayStatus == AttendanceStatus.checkedIn &&
            s.records.isNotEmpty)),
      );

      // 2. Submit check-out
      bloc.add(const RecordPunch(
        eventType: AttendanceEventType.checkOut,
        latitude: 12.971598, longitude: 77.594562, distanceMeters: 45.0,
      ));

      await expectLater(
        bloc.stream,
        emits(predicate<AttendanceState>((s) =>
            s is AttendanceLoaded &&
            s.todayStatus == AttendanceStatus.checkedOut &&
            s.records.first.checkOutTime != null)),
      );

      // 3. Submit check-in again to verify multiple check-ins daily
      bloc.add(const RecordPunch(
        eventType: AttendanceEventType.checkIn,
        latitude: 12.971598, longitude: 77.594562, distanceMeters: 45.0,
      ));

      await expectLater(
        bloc.stream,
        emits(predicate<AttendanceState>((s) =>
            s is AttendanceLoaded && s.todayStatus == AttendanceStatus.checkedIn)),
      );

      // 4. Verify getAttendanceHistory returns the updated records
      final history = await repo.getAttendanceHistory('2026-11');
      expect(history.records, isNotEmpty);
      expect(history.records.first.status, AttendanceStatus.checkedIn);
      expect(history.records.first.checkInTime, isNotNull);

      await bloc.close();
    });
  });
}

