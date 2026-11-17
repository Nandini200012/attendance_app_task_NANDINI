import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_register_app/main.dart';
import 'package:attendance_register_app/shared/models/attendance_enums.dart';
import 'package:attendance_register_app/shared/models/attendance_event.dart';
import 'package:attendance_register_app/features/attendance/presentation/widgets/location_permission_dialog.dart';
import 'package:attendance_register_app/features/sync/presentation/widgets/sync_event_tile.dart';

void main() {
  testWidgets(
    'REBS HRMS initial smoke test loads main navigation and branding',
    (WidgetTester tester) async {
      await tester.pumpWidget(RebsHrmsApp());
      await tester.pumpAndSettle();

      expect(find.text('Unable to Load Data'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Attendance'), findsAtLeastNWidgets(1));
      expect(find.text('Leave'), findsOneWidget);
    },
  );

  testWidgets(
    'LocationPermissionDialog displays prompt and returns correct user choice',
    (WidgetTester tester) async {
      LocationState? selectedState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  selectedState = await LocationPermissionDialog.show(context);
                },
                child: const Text('Ask Permission'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ask Permission'));
      await tester.pumpAndSettle();

      expect(
        find.text('Allow "REBS HRMS" to access this device\'s location?'),
        findsOneWidget,
      );
      expect(find.text('While using the app'), findsOneWidget);
      expect(find.text('Only this time'), findsOneWidget);
      expect(find.text("Don't allow"), findsOneWidget);

      await tester.tap(find.text('While using the app'));
      await tester.pumpAndSettle();

      expect(selectedState, LocationState.granted);
    },
  );

  testWidgets(
    'SyncEventTile renders long UUID on narrow screen without overflow',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final longUuidEvent = AttendanceEvent(
        eventId: 'evt-17f96d4d-4d36-4600-858b-648a0f53ec81',
        eventType: AttendanceEventType.checkIn,
        timestamp: DateTime(2026, 11, 16, 9, 15, 0),
        latitude: 10.6940374,
        longitude: 76.7345539,
        distanceMeters: 48.2,
        syncStatus: SyncStatus.pending,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SyncEventTile(event: longUuidEvent, onTap: () {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        find.text(longUuidEvent.displayId),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'SyncEventTile renders long UUID on narrow screen without overflow',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final longUuidEvent = AttendanceEvent(
        eventId: 'evt-17f96d4d-4d36-4600-858b-648a0f53ec81',
        eventType: AttendanceEventType.checkIn,
        timestamp: DateTime(2026, 11, 16, 9, 15, 0),
        latitude: 10.6940374,
        longitude: 76.7345539,
        distanceMeters: 48.2,
        syncStatus: SyncStatus.pending,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SyncEventTile(event: longUuidEvent, onTap: () {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        find.text(longUuidEvent.displayId),
        findsOneWidget,
      );
    },
  );
}
