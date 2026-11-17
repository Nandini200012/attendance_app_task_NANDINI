import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_register_app/features/attendance/bloc/attendance_bloc.dart';
import 'package:attendance_register_app/features/attendance/bloc/attendance_event.dart';
import 'package:attendance_register_app/features/attendance/bloc/attendance_state.dart';
import 'package:attendance_register_app/features/attendance/data/repositories/attendance_repository.dart';
import 'package:attendance_register_app/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:attendance_register_app/features/dashboard/bloc/dashboard_event.dart';
import 'package:attendance_register_app/features/dashboard/bloc/dashboard_state.dart';
import 'package:attendance_register_app/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:attendance_register_app/features/leave/bloc/leave_bloc.dart';
import 'package:attendance_register_app/features/leave/bloc/leave_event.dart';
import 'package:attendance_register_app/features/leave/bloc/leave_state.dart';
import 'package:attendance_register_app/features/leave/data/repositories/leave_repository.dart';
import 'package:attendance_register_app/features/sync/bloc/sync_bloc.dart';
import 'package:attendance_register_app/features/sync/bloc/sync_event.dart';
import 'package:attendance_register_app/features/sync/bloc/sync_state.dart';
import 'package:attendance_register_app/features/sync/data/repositories/sync_repository.dart';
import 'package:attendance_register_app/features/sync/data/services/sync_storage_service.dart';

void main() {
  late SyncStorageService storage;

  setUp(() {
    storage = SyncStorageService();
  });

  test('DashboardBloc emits DashboardLoaded on LoadDashboardData', () async {
    final repo = DashboardRepository(storageService: storage);
    final bloc = DashboardBloc(repository: repo);

    expect(
      bloc.stream,
      emitsInOrder([isA<DashboardLoading>(), isA<DashboardLoaded>()]),
    );

    bloc.add(const LoadDashboardData());
  });

  test(
    'AttendanceBloc emits AttendanceLoaded on LoadAttendanceMonth',
    () async {
      final repo = AttendanceRepository(storageService: storage);
      final bloc = AttendanceBloc(repository: repo);

      expect(
        bloc.stream,
        emitsInOrder([isA<AttendanceLoading>(), isA<AttendanceLoaded>()]),
      );

      bloc.add(const LoadAttendanceMonth('2026-11'));
    },
  );

  test('LeaveBloc emits LeaveLoaded on LoadLeaveData', () async {
    final repo = LeaveRepository(storageService: storage);
    final bloc = LeaveBloc(repository: repo);

    expect(
      bloc.stream,
      emitsInOrder([isA<LeaveLoading>(), isA<LeaveLoaded>()]),
    );

    bloc.add(const LoadLeaveData());
  });

  test('SyncBloc emits SyncLoaded on LoadSyncData', () async {
    final repo = SyncRepository(storageService: storage);
    final bloc = SyncBloc(repository: repo);

    expect(bloc.stream, emitsInOrder([isA<SyncLoaded>()]));

    bloc.add(const LoadSyncData());
  });
}
