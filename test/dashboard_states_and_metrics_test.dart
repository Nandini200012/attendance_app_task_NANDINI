import 'package:attendance_register_app/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:attendance_register_app/features/dashboard/bloc/dashboard_state.dart';
import 'package:attendance_register_app/features/dashboard/data/models/dashboard_data.dart';
import 'package:attendance_register_app/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:attendance_register_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:attendance_register_app/features/sync/data/services/sync_storage_service.dart';
import 'package:attendance_register_app/shared/models/attendance_enums.dart';
import 'package:attendance_register_app/shared/models/attendance_record.dart';
import 'package:attendance_register_app/shared/models/employee_model.dart';
import 'package:attendance_register_app/shared/models/leave_model.dart';
import 'package:attendance_register_app/shared/widgets/attendance_record_tile.dart';
import 'package:attendance_register_app/shared/widgets/empty_state_view.dart';
import 'package:attendance_register_app/shared/widgets/offline_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockDashboardBloc extends DashboardBloc {
  _MockDashboardBloc(DashboardState initial)
    : super(
        repository: DashboardRepository(storageService: SyncStorageService()),
      ) {
    emit(initial);
  }
}

Widget _wrap(DashboardBloc bloc) => MaterialApp(
  home: BlocProvider<DashboardBloc>.value(
    value: bloc,
    child: DashboardScreen(
      initialLoadingDuration: Duration.zero,
      onNavigateToAttendance: () {},
      onNavigateToLeave: () {},
      onNavigateToSync: () {},
      onNavigateToHistory: () {},
      onNavigateToEventDetails: (_) {},
    ),
  ),
);

void main() {
  final emp = const EmployeeModel(
    id: 'emp-001',
    employeeCode: 'EMP-2048',
    name: 'Nandini N',
    designation: 'Senior Flutter Specialist',
    department: 'Mobile Engineering',
    email: 'nandini.n@rebs.io',
  );

  testWidgets('Displays attendance metrics, leave balance, and 5 recent records', (tester) async {
    final records = List.generate(
      6,
      (i) => AttendanceRecord(
        id: 'rec-$i',
        date: DateTime(2026, 11, 10 + i),
        checkInTime: DateTime(2026, 11, 10 + i, 9, 15),
        checkOutTime: DateTime(2026, 11, 10 + i, 17, 30),
        workingDuration: '8h 15m',
        status: AttendanceStatus.checkedOut,
        syncStatus: SyncStatus.synced,
      ),
    );

    final data = DashboardData(
      employee: emp,
      todayStatus: AttendanceStatus.checkedIn,
      checkInTime: '08:45 AM',
      checkOutTime: '--:--',
      workingDuration: '4h 30m',
      leaveBalance: const LeaveBalance(casualAvailable: 8, casualTotal: 12, sickAvailable: 5, sickTotal: 10),
      recentRecords: records.take(5).toList(),
      pendingSyncCount: 0,
      isOffline: false,
    );

    final bloc = _MockDashboardBloc(DashboardLoaded(data));
    await tester.pumpWidget(_wrap(bloc));
    await tester.pumpAndSettle();

    expect(find.text('Checked In'), findsOneWidget);
    expect(find.text('08:45 AM'), findsOneWidget);
    expect(find.text('4h 30m'), findsOneWidget);
    expect(find.text('13 Days Left'), findsOneWidget);
    expect(find.byType(AttendanceRecordTile), findsNWidgets(5));
    bloc.close();
  });

  testWidgets('Displays offline banner when isOffline is true', (tester) async {
    final data = DashboardData(
      employee: emp,
      todayStatus: AttendanceStatus.notCheckedIn,
      checkInTime: '--:--',
      checkOutTime: '--:--',
      workingDuration: '--',
      leaveBalance: LeaveBalance.empty,
      recentRecords: const [],
      pendingSyncCount: 2,
      isOffline: true,
    );

    final bloc = _MockDashboardBloc(DashboardLoaded(data));
    await tester.pumpWidget(_wrap(bloc));
    await tester.pumpAndSettle();

    expect(find.byType(OfflineBanner), findsOneWidget);
    expect(find.text('2 attendance events recorded offline.'), findsOneWidget);
    expect(find.byType(EmptyStateView), findsOneWidget);
    bloc.close();
  });
}
