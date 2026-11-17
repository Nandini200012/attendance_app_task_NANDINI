import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_register_app/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:attendance_register_app/features/dashboard/bloc/dashboard_state.dart';
import 'package:attendance_register_app/features/dashboard/data/models/dashboard_data.dart';
import 'package:attendance_register_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:attendance_register_app/shared/models/employee_model.dart';
import 'package:attendance_register_app/shared/widgets/error_state_view.dart';

import 'package:attendance_register_app/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:attendance_register_app/features/sync/data/services/sync_storage_service.dart';

class TestDashboardBloc extends DashboardBloc {
  TestDashboardBloc(DashboardState initial)
    : super(
        repository: DashboardRepository(storageService: SyncStorageService()),
      ) {
    emit(initial);
  }

  void emitState(DashboardState state) => emit(state);
}

void main() {
  group('Dashboard Screen UI States Verification', () {
    late TestDashboardBloc bloc;

    setUp(() {
      bloc = TestDashboardBloc(const DashboardLoading());
    });

    tearDown(() {
      bloc.close();
    });

    Widget createTestApp(DashboardBloc testBloc) {
      return MaterialApp(
        home: BlocProvider<DashboardBloc>.value(
          value: testBloc,
          child: DashboardScreen(
            onNavigateToAttendance: () {},
            onNavigateToLeave: () {},
            onNavigateToSync: () {},
            onNavigateToHistory: () {},
            onNavigateToEventDetails: (_) {},
          ),
        ),
      );
    }

    testWidgets('1. Loading State: renders LinearProgressIndicator', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp(bloc));
      await tester.pump();

      // Verify the indeterminate loading bar is present
      expect(
        find.byWidgetPredicate(
          (w) => w is LinearProgressIndicator && w.value == null,
        ),
        findsOneWidget,
      );
    });

    testWidgets('2. Success State: displays API employee data in UI', (
      tester,
    ) async {
      final employee = EmployeeModel.fromJson({
        'id': 'emp-001',
        'employee_id': 'EMP-2048',
        'employee_name': 'Nandini N',
        'designation': 'Senior Flutter Specialist',
        'department': 'Mobile Engineering',
        'email': 'nandini.n@rebs.io',
      });

      final loadedData = DashboardData(
        employee: employee,
        todayStatus: DashboardData.fallback.todayStatus,
        checkInTime: '09:15 AM',
        checkOutTime: '--:--',
        workingDuration: '7h 45m',
        leaveBalance: DashboardData.fallback.leaveBalance,
        recentRecords: DashboardData.fallback.recentRecords,
        pendingSyncCount: 0,
        isOffline: false,
      );

      bloc.emitState(DashboardLoaded(loadedData));

      await tester.pumpWidget(createTestApp(bloc));
      await tester.pumpAndSettle();

      // Verify employee name in header and card
      expect(find.text('Nandini N'), findsAtLeastNWidgets(1));
      // Verify corporate code
      expect(find.text('EMP-2048'), findsOneWidget);
      // Verify designation
      expect(find.text('Senior Flutter Specialist'), findsOneWidget);
      // Verify department
      expect(find.text('Mobile Engineering'), findsOneWidget);
      // Verify initials in avatar circle
      expect(find.text('NN'), findsOneWidget);
    });

    testWidgets('3. Error State: renders ErrorStateView and Try Again button', (
      tester,
    ) async {
      bloc.emitState(
        const DashboardError('Could not connect to mock REST API.'),
      );

      await tester.pumpWidget(createTestApp(bloc));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorStateView), findsOneWidget);
      expect(find.text('Unable to Load Data'), findsOneWidget);
      expect(find.text('Could not connect to mock REST API.'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });
  });
}
