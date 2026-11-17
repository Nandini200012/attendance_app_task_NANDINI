import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/attendance/bloc/attendance_bloc.dart';
import 'features/attendance/bloc/attendance_event.dart';
import 'features/attendance/data/repositories/attendance_repository.dart';
import 'features/dashboard/bloc/dashboard_bloc.dart';
import 'features/dashboard/bloc/dashboard_event.dart';
import 'features/dashboard/data/repositories/dashboard_repository.dart';
import 'features/leave/bloc/leave_bloc.dart';
import 'features/leave/bloc/leave_event.dart';
import 'features/leave/data/repositories/leave_repository.dart';
import 'features/navigation/presentation/screens/main_navigation_screen.dart';
import 'features/sync/bloc/sync_bloc.dart';
import 'features/sync/bloc/sync_event.dart';
import 'features/sync/data/repositories/sync_repository.dart';
import 'features/sync/data/services/cache_storage_service.dart';
import 'features/sync/data/services/sync_storage_service.dart';

/// Application entry point for REBS HRMS Employee App.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final storageService = SyncStorageService();
  await storageService.init();

  final cacheService = CacheStorageService();
  await cacheService.init();

  runApp(
    RebsHrmsApp(storageService: storageService, cacheService: cacheService),
  );
}

/// Root widget configuring theme, repositories, and BLoC state providers.
class RebsHrmsApp extends StatelessWidget {
  final SyncStorageService _storageService;
  final CacheStorageService _cacheService;

  RebsHrmsApp({
    super.key,
    SyncStorageService? storageService,
    CacheStorageService? cacheService,
  }) : _storageService = storageService ?? SyncStorageService(),
       _cacheService = cacheService ?? CacheStorageService();

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (_) => DashboardRepository(
            storageService: _storageService,
            cacheService: _cacheService,
          ),
        ),
        RepositoryProvider(
          create: (_) => AttendanceRepository(
            storageService: _storageService,
            cacheService: _cacheService,
          ),
        ),
        RepositoryProvider(
          create: (_) => LeaveRepository(
            storageService: _storageService,
            cacheService: _cacheService,
          ),
        ),
        RepositoryProvider(
          create: (_) => SyncRepository(storageService: _storageService),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) =>
                DashboardBloc(repository: ctx.read<DashboardRepository>())
                  ..add(const LoadDashboardData()),
          ),
          BlocProvider(
            create: (ctx) =>
                AttendanceBloc(repository: ctx.read<AttendanceRepository>())
                  ..add(const LoadAttendanceMonth('2026-11')),
          ),
          BlocProvider(
            create: (ctx) =>
                LeaveBloc(repository: ctx.read<LeaveRepository>())
                  ..add(const LoadLeaveData()),
          ),
          BlocProvider(
            create: (ctx) =>
                SyncBloc(repository: ctx.read<SyncRepository>())
                  ..add(const LoadSyncData()),
          ),
        ],
        child: MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const MainNavigationScreen(),
        ),
      ),
    );
  }
}
