# REBS HRMS — Attendance & Leave App

A simple and resilient offline-first employee application built with **Flutter** (BLoC & Clean Architecture) and backed by a local **Node.js / Express** mock API.

---

## 1. Architecture

- **Pattern**: Clean Architecture + BLoC pattern.
- **Unidirectional Data Flow**: UI triggers events $\to$ BLoC emits immutable state $\to$ UI reacts.
- **Local Storage**: Hive NoSQL for offline caching and persistent operation queues.
- **Sync & Idempotency**: Pending actions are stored in a FIFO queue with client UUIDs (`eventId`). Retries sending duplicate IDs return `409 Conflict`, which the client handles as an idempotent success without creating duplicates.
- **Code Style**: Strict $\le 150$ lines per Dart file across the entire project.

---

## 2. Setup

### 1. Start Mock Server (Port 3000)
```bash
cd mock_api
npm install
npm start
```
*Health check:* `curl http://localhost:3000/health`

### 2. Run the Mobile App
```bash
flutter pub get

# macOS Desktop
flutter run -d macos

# Android Emulator
flutter run -d emulator-5554

# Android Physical Device (via USB)
adb reverse tcp:3000 tcp:3000 && flutter run
```

### 3. Run Automated Tests
```bash
flutter test
```
*(All 62 tests passing)*

---

## 3. Assumptions

- **Single Employee Profile**: Uses preconfigured employee Nandini N (`EMP-2048`). Login and user switching are out of scope.
- **Single Daily Shift**: One attendance session per day (Check-in before Check-out). No split or overnight shifts.
- **Geofence Parameters**: Fixed office location (`10.6940374, 76.7345539`) with a 200m valid radius.
- **Leave Rules**: All calendar days count as leave days (weekends/holidays ignored). Reason must be $\ge 10$ characters. No backdating or overlapping leave dates.
- **GPS Simulation for Reviewers**: Use the AppBar menu (`...`) on the Attendance screen to simulate *Inside Office*, *Outside Office*, *GPS Disabled*, and *Permission Denied*.

---

## 4. Completed Features

- **Dashboard**: Employee profile card, live shift duration timer, leave balance widgets, and recent attendance list.
- **Attendance Check-In / Check-Out**: GPS geofenced punch actions, location permission handling, and duplicate-tap prevention.
- **Attendance History**: Clean list of daily punches, working hours, and sync status badges (`Pending`, `Synced`).
- **Leave Application**: Date pickers with instant validation (past date prevention, date overlap checks, reason character count) and cached offline view.
- **Offline Sync Management**: Queues actions locally when offline, auto-syncs on reconnection in FIFO order, and includes a manual "Sync Now" button.

---

## 5. Limitations

- **Terminated Background Sync**: Sync runs automatically on app launch, resume, connectivity restoration, or manual trigger. Background execution while the app is fully terminated is out of scope.
- **Single Profile**: Multi-tenant authentication and supervisor approval portals are not included.
- **Device Clock**: Client uses device clock; production backends must cross-check server timestamps for clock skew.

---

## 6. Time Spent

| Phase | Focus Areas | Time Spent |
| :--- | :--- | :--- |
| **Frontend** | UI screens, BLoC state management, form validation, GPS simulator, and Hive caching | **2 hours** |
| **Backend** | Node.js/Express server, REST routes, Haversine geofencing, and idempotency logic | **3 hours** |
| **Testing** | Automated unit, widget, and integration tests (62 passing) + static analysis | **1 hour** |
| **Total** | | **6 hours** |
