import 'package:attendance_register_app/features/leave/bloc/leave_bloc.dart';
import 'package:attendance_register_app/features/leave/bloc/leave_state.dart';
import 'package:attendance_register_app/features/leave/data/repositories/leave_repository.dart';
import 'package:attendance_register_app/features/leave/presentation/screens/apply_leave_screen.dart';
import 'package:attendance_register_app/features/leave/presentation/screens/leave_management_screen.dart';
import 'package:attendance_register_app/features/leave/presentation/utils/leave_validator.dart';
import 'package:attendance_register_app/features/sync/data/services/sync_storage_service.dart';
import 'package:attendance_register_app/shared/models/leave_model.dart';
import 'package:attendance_register_app/shared/widgets/leave_request_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {LeaveBalance? balance, List<LeaveRequest>? requests}) {
  final storage = SyncStorageService();
  final repo = LeaveRepository(storageService: storage);
  final bloc = LeaveBloc(repository: repo);
  bloc.emit(LeaveLoaded(
    balance: balance ?? LeaveBalance.mockBalance,
    requests: requests ?? LeaveRequest.mockRequests,
  ));
  return MultiBlocProvider(
    providers: [
      BlocProvider<LeaveBloc>.value(value: bloc),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  group('LeaveValidator Unit Tests', () {
    final balance = LeaveBalance.mockBalance;
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);

    test('Rejects start dates in the past', () {
      final past = todayNorm.subtract(const Duration(days: 2));
      final err = LeaveValidator.validate(
        startDate: past,
        endDate: todayNorm,
        requestedDays: 3,
        reason: 'Reason of sufficient length',
        selectedType: LeaveType.casual,
        balance: balance,
      );
      expect(err, contains('Start date cannot be before the current company date'));
    });

    test('Rejects requested days exceeding available quota', () {
      final err = LeaveValidator.validate(
        startDate: todayNorm,
        endDate: todayNorm.add(const Duration(days: 4)),
        requestedDays: 5,
        reason: 'Reason of sufficient length',
        selectedType: LeaveType.casual,
        balance: balance,
      );
      expect(err, contains('exceed the available balance'));
    });

    test('Rejects dates overlapping existing Pending/Approved requests', () {
      final existing = [
        LeaveRequest(
          id: 'lev-1',
          leaveType: LeaveType.casual,
          startDate: todayNorm.add(const Duration(days: 3)),
          endDate: todayNorm.add(const Duration(days: 5)),
          requestedDays: 3,
          submissionDate: todayNorm,
          status: LeaveStatus.pending,
          reason: 'Existing trip',
        ),
      ];

      final err = LeaveValidator.validate(
        startDate: todayNorm.add(const Duration(days: 4)),
        endDate: todayNorm.add(const Duration(days: 6)),
        requestedDays: 3,
        reason: 'Overlapping leave justification',
        selectedType: LeaveType.casual,
        balance: balance,
        existingRequests: existing,
      );
      expect(err, contains('Dates overlap with an existing'));
    });

    test('Accepts valid non-overlapping leave parameters', () {
      final err = LeaveValidator.validate(
        startDate: todayNorm,
        endDate: todayNorm.add(const Duration(days: 1)),
        requestedDays: 2,
        reason: 'Valid justification with more than 10 characters',
        selectedType: LeaveType.casual,
        balance: balance,
      );
      expect(err, isNull);
    });
  });

  group('Leave UI Validation & Display Tests', () {
    testWidgets('Submit button disabled until valid reason entered', (tester) async {
      await tester.pumpWidget(_wrap(
        const ApplyLeaveScreen(initialLoadingDuration: Duration.zero),
      ));
      await tester.pumpAndSettle();

      final btnFinder = find.widgetWithText(ElevatedButton, 'Submit Leave Application');
      final btn = tester.widget<ElevatedButton>(btnFinder);
      expect(btn.onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'Personal family event trip');
      await tester.pumpAndSettle();

      final enabledBtn = tester.widget<ElevatedButton>(btnFinder);
      expect(enabledBtn.onPressed, isNotNull);
    });

    testWidgets('Displays error message when using the same date as an existing request', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final existingReq = LeaveRequest(
        id: 'LEV-EXISTING-1', leaveType: LeaveType.casual, startDate: today,
        endDate: today, requestedDays: 1, submissionDate: today,
        status: LeaveStatus.pending, reason: 'Existing appointment',
      );
      await tester.pumpWidget(_wrap(
        const ApplyLeaveScreen(initialLoadingDuration: Duration.zero),
        requests: [existingReq],
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('already applied for leave on this date'), findsOneWidget);
    });

    testWidgets('LeaveManagementScreen displays Pending and Approved statuses and filter chips', (tester) async {
      await tester.pumpWidget(_wrap(LeaveManagementScreen(
        initialLoadingDuration: Duration.zero,
        onNavigateToApplyLeave: () {},
      )));
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Pending'), findsWidgets);
      expect(find.text('Approved'), findsWidgets);
      expect(find.byType(LeaveRequestTile), findsNWidgets(2));
    });
  });
}
