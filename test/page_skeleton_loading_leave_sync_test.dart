import 'package:attendance_register_app/features/leave/bloc/leave_bloc.dart';
import 'package:attendance_register_app/features/leave/bloc/leave_event.dart';
import 'package:attendance_register_app/features/leave/data/repositories/leave_repository.dart';
import 'package:attendance_register_app/features/leave/presentation/screens/apply_leave_screen.dart';
import 'package:attendance_register_app/features/leave/presentation/screens/leave_management_screen.dart';
import 'package:attendance_register_app/features/sync/bloc/sync_bloc.dart';
import 'package:attendance_register_app/features/sync/bloc/sync_event.dart';
import 'package:attendance_register_app/features/sync/data/repositories/sync_repository.dart';
import 'package:attendance_register_app/features/sync/data/services/sync_storage_service.dart';
import 'package:attendance_register_app/features/sync/presentation/screens/sync_management_screen.dart';
import 'package:attendance_register_app/shared/widgets/page_skeleton_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildWrapper({required Widget child}) {
  final storage = SyncStorageService();
  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider(
        create: (_) => LeaveRepository(storageService: storage),
      ),
      RepositoryProvider(
        create: (_) => SyncRepository(storageService: storage),
      ),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (c) => LeaveBloc(
            repository: c.read<LeaveRepository>(),
          )..add(const LoadLeaveData()),
        ),
        BlocProvider(
          create: (c) => SyncBloc(
            repository: c.read<SyncRepository>(),
            enableAutoSync: false,
          )..add(const LoadSyncData()),
        ),
      ],
      child: MaterialApp(home: child),
    ),
  );
}

void main() {
  testWidgets(
      'LeaveManagementScreen renders PageSkeletonView initially for 1.8s',
      (tester) async {
    await tester.pumpWidget(
      _buildWrapper(
        child: LeaveManagementScreen(
          initialLoadingDuration: const Duration(milliseconds: 1800),
          onNavigateToApplyLeave: () {},
        ),
      ),
    );

    expect(find.byType(PageSkeletonView), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pumpAndSettle();

    expect(find.byType(PageSkeletonView), findsNothing);
  });

  testWidgets(
      'SyncManagementScreen renders PageSkeletonView initially for 1.8s',
      (tester) async {
    await tester.pumpWidget(
      _buildWrapper(
        child: SyncManagementScreen(
          initialLoadingDuration: const Duration(milliseconds: 1800),
          onNavigateToEventDetails: (_) {},
        ),
      ),
    );

    expect(find.byType(PageSkeletonView), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pumpAndSettle();

    expect(find.byType(PageSkeletonView), findsNothing);
  });

  testWidgets('ApplyLeaveScreen renders PageSkeletonView initially for 1.8s',
      (tester) async {
    await tester.pumpWidget(
      _buildWrapper(
        child: const ApplyLeaveScreen(
          initialLoadingDuration: Duration(milliseconds: 1800),
        ),
      ),
    );

    expect(find.byType(PageSkeletonView), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pumpAndSettle();

    expect(find.byType(PageSkeletonView), findsNothing);
  });
}

