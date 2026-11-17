import 'package:attendance_register_app/features/attendance/bloc/attendance_bloc.dart';
import 'package:attendance_register_app/features/attendance/bloc/attendance_event.dart';
import 'package:attendance_register_app/features/attendance/data/repositories/attendance_repository.dart';
import 'package:attendance_register_app/features/attendance/presentation/screens/attendance_history_screen.dart';
import 'package:attendance_register_app/features/attendance/presentation/screens/attendance_overview_screen.dart';
import 'package:attendance_register_app/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:attendance_register_app/features/dashboard/bloc/dashboard_event.dart';
import 'package:attendance_register_app/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:attendance_register_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:attendance_register_app/features/sync/data/services/cache_storage_service.dart';
import 'package:attendance_register_app/features/sync/data/services/sync_storage_service.dart';
import 'package:attendance_register_app/shared/widgets/page_skeleton_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildWrapper({required Widget child}) {
  final storage = SyncStorageService();
  final cache = CacheStorageService();
  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider(
        create: (_) =>
            DashboardRepository(storageService: storage, cacheService: cache),
      ),
      RepositoryProvider(
        create: (_) =>
            AttendanceRepository(storageService: storage, cacheService: cache),
      ),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (c) => DashboardBloc(
            repository: c.read<DashboardRepository>(),
          )..add(const LoadDashboardData()),
        ),
        BlocProvider(
          create: (c) => AttendanceBloc(
            repository: c.read<AttendanceRepository>(),
          )..add(const LoadAttendanceMonth('2026-11')),
        ),
      ],
      child: MaterialApp(home: child),
    ),
  );
}

void main() {
  testWidgets('DashboardScreen renders PageSkeletonView initially for 1.8s',
      (tester) async {
    await tester.pumpWidget(
      _buildWrapper(
        child: DashboardScreen(
          initialLoadingDuration: const Duration(milliseconds: 1800),
          onNavigateToAttendance: () {},
          onNavigateToLeave: () {},
          onNavigateToSync: () {},
          onNavigateToHistory: () {},
          onNavigateToEventDetails: (_) {},
        ),
      ),
    );

    expect(find.byType(PageSkeletonView), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pumpAndSettle();

    expect(find.byType(PageSkeletonView), findsNothing);
  });

  testWidgets(
      'AttendanceOverviewScreen renders PageSkeletonView initially for 1.8s',
      (tester) async {
    await tester.pumpWidget(
      _buildWrapper(
        child: AttendanceOverviewScreen(
          initialLoadingDuration: const Duration(milliseconds: 1800),
          onNavigateToHistory: () {},
          onNavigateToEventDetails: (_) {},
        ),
      ),
    );

    expect(find.byType(PageSkeletonView), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pumpAndSettle();

    expect(find.byType(PageSkeletonView), findsNothing);
  });

  testWidgets(
      'AttendanceHistoryScreen renders PageSkeletonView initially for 1.8s',
      (tester) async {
    await tester.pumpWidget(
      _buildWrapper(
        child: AttendanceHistoryScreen(
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
}
