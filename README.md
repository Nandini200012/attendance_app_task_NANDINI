# REBS HRMS — Attendance & Leave App

[![Tests](https://img.shields.io/badge/Tests-62%2F62%20Passing%20(100%25)-brightgreen)]()
[![Code Quality](https://img.shields.io/badge/Code%20Style-Max%20150%20lines%2Ffile-success)]()
[![Flutter](https://img.shields.io/badge/Flutter-3.10%2B-blue)]()
[![Backend](https://img.shields.io/badge/Backend-Node.js%20%2F%20Express-green)]()

An offline-first enterprise mobile application built with **Flutter** (BLoC & Clean Architecture) and backed by a local **Node.js / Express** REST API. Supports offline attendance check-in/out, leave applications, automatic FIFO sync with idempotency, and GPS geofencing.

---

## 1. Architecture

- **Pattern**: Clean Architecture + BLoC (Business Logic Component).
- **Unidirectional Data Flow**: UI dispatches events $\to$ BLoC processes state $\to$ UI reacts immutably.
- **Offline Storage**: Hive NoSQL (`sync_operations_v2.hive`, `rebs_app_cache.hive`).
- **Sync & Idempotency**: Persistent FIFO queue. Every action generates a unique client UUID (`eventId`). The server detects duplicates and responds with `HTTP 409 Conflict`, which the sync engine treats as an idempotent success so retries never create duplicate server records.
- **Code Modularity**: All 114+ Dart files strictly adhere to $\le 150$ lines per file.

---

## 2. Setup & Installation

### Step 1: Start Mock REST API (Port 3000)
```bash
cd mock_api
npm install
npm start
```
*Verify server health:* `curl http://localhost:3000/health`

### Step 2: Run Flutter App
```bash
flutter pub get

# macOS Desktop
flutter run -d macos

# Android Emulator (auto-routes 10.0.2.2 to localhost:3000)
flutter run -d emulator-5554

# Physical Android Device (over USB)
adb reverse tcp:3000 tcp:3000 && flutter run
```

### Step 3: Run Automated Tests
```bash
flutter test
```
*(62/62 unit, widget, and integration tests passing)*

---

## 3. Assumptions & Domain Rules

- **Single Preconfigured Employee**: Profile `EMP-2048` (Nandini N). User authentication/login is outside assignment scope.
- **Attendance Rules**: One session per working day (Check-out permitted only after Check-in). No overnight shifts.
- **Geofence Perimeter**: Office coordinates (`10.6940374, 76.7345539`) with a 200m radius.
- **Leave Application**: All calendar days count (weekends/holidays ignored). Reason must be $\ge 10$ characters. Start date cannot be in the past, and dates cannot overlap existing requests.
- **Reviewer GPS Simulation**: AppBar popup menu (`...`) allows instant switching between:
  - `In Office (45m)`
  - `Outside Perimeter (850m)`
  - `GPS Disabled`
  - `Permission Denied`
  - `Permanently Denied`

---

## 4. Completed Features

1. **Employee Dashboard**: Shift timer, live leave quotas, recent punch history, and cached offline viewing.
2. **Attendance Check-In & Check-Out**: Single-tap actions guarded by 200m GPS perimeter, permission dialogs, and duplicate-tap prevention.
3. **Attendance History**: Clutter-free list displaying punch dates, shift durations, working hours, and sync states.
4. **Leave Management**: Balance counters, application form with real-time validation (overlap prevention, minimum character limits), and offline cached list.
5. **Unified Offline Sync Queue**: Queues pending actions offline in Hive, auto-syncs on reconnection in FIFO order, handles network timeouts gracefully, and includes a manual "Sync Now" action.

---

## 5. Limitations

- **Terminated Background Sync**: Sync triggers on app launch, resume, network restoration, or manual trigger; background execution while the app process is terminated is outside assignment scope.
- **Single Employee Profile**: Multi-tenant login and supervisor approvals are not modeled.
- **Device Clock Dependency**: Timestamps rely on device time; a production server should validate against clock skew.

---

## 6. Time Spent

| Phase | Description | Time Spent |
| :--- | :--- | :--- |
| **Frontend Development** | UI screens, BLoCs, custom widgets, validation, location simulation, and Hive caching | **3 hours** |
| **Backend API** | Node.js/Express server, REST endpoints, Haversine geofencing, and idempotency handling | **2 hours** |
| **Testing & Verification** | 62 automated unit/widget/integration tests, edge cases, and static analysis | **1 hour** |
| **Total** | | **6 hours** |
