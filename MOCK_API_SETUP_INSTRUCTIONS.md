# REBS HRMS — Mock REST API & Environment Setup Guide

This document provides complete instructions for configuring, launching, testing, and troubleshooting the **Node.js / Express Mock REST API** and connecting it with the **Flutter Employee Mobile Application** across all supported platforms (macOS Desktop, Android Emulator, Physical Android Device, iOS Simulator, and Web).

---

## Table of Contents

1. [Mock API Architecture & Configuration](#1-mock-api-architecture--configuration)
2. [Prerequisites](#2-prerequisites)
3. [Starting the Mock API Server](#3-starting-the-mock-api-server)
4. [Connecting the Flutter Mobile App](#4-connecting-the-flutter-mobile-app)
   - [Option A: macOS Desktop (Recommended for Fast Review)](#option-a-macos-desktop-recommended-for-fast-review)
   - [Option B: Android Emulator](#option-b-android-emulator)
   - [Option C: Physical Android Device](#option-c-physical-android-device)
   - [Option D: iOS Simulator](#option-d-ios-simulator)
   - [Option E: Chrome Web](#option-e-chrome-web)
5. [API Endpoint Reference & Verification cURLs](#5-api-endpoint-reference--verification-curls)
6. [Testing Offline Draining & Auto-Sync](#6-testing-offline-draining--auto-sync)
7. [Simulating Location / Geofence for Reviewers](#7-simulating-location--geofence-for-reviewers)
8. [Troubleshooting & FAQs](#8-troubleshooting--faqs)

---

## 1. Mock API Architecture & Configuration

The mock backend is a standalone **Node.js Express** server located in the `mock_api/` directory.

- **Port**: `3000` (configurable via `PORT` environment variable).
- **Protocol**: HTTP/1.1 REST (`application/json`).
- **Database**: Local JSON persistence at `mock_api/src/data/database.json`.
- **Preconfigured Employee**: Nandini N (`EMP-2048`, ID: `emp-001`, Dept: `Engineering`).
- **Configured Office Geofence**:
  - Site: `REBS HQ (Bangalore Tech Park)`
  - Latitude: `10.6940374`
  - Longitude: `76.7345539`
  - Allowed Radius: `200.0 meters`

### Standard Response Envelopes

All responses follow a consistent status envelope:

#### Success (`StatusCode: 6000`)
```json
{
  "StatusCode": 6000,
  "message": {
    "title": "Success",
    "body": "Punched check_in successfully."
  },
  "data": { ... }
}
```

#### Business / Validation Error (`StatusCode: 6001`)
```json
{
  "StatusCode": 6001,
  "message": {
    "title": "Validation Error",
    "body": "Check-out is permitted only after check-in."
  },
  "data": null
}
```

---

## 2. Prerequisites

Ensure the following tools are installed on your machine:

| Tool | Minimum Version | Verification Command |
| :--- | :--- | :--- |
| **Node.js** | `>= 18.0.0` | `node -v` |
| **npm** | `>= 9.0.0` | `npm -v` |
| **Flutter SDK** | `>= 3.10.0` | `flutter --version` |
| **Dart SDK** | `>= 3.10.0` | `dart --version` |

---

## 3. Starting the Mock API Server

Open a terminal window and navigate to the `mock_api` folder:

```bash
# 1. Navigate to mock_api directory
cd mock_api

# 2. Install dependencies (express, cors, uuid) - first time only
npm install

# 3. Start the server
npm start
```

### Expected Startup Output
```text
=======================================================
 REBS HRMS Mock REST API Server running on port 3000
 Health Check: http://localhost:3000/health
 Employee:     http://localhost:3000/employee/me
 Attendance:   http://localhost:3000/attendance
 Leave:        http://localhost:3000/leave/balance
=======================================================
```

### Verify Service Health
In another terminal tab, run:
```bash
curl http://localhost:3000/health
```
**Expected Response**:
```json
{"status":"healthy","uptime":3.15,"timestamp":"2026-11-17T...","version":"1.0.0"}
```

### Run Backend Integration Tests
To verify all mock API routes, validations, idempotency, and geofence calculations:
```bash
node test_api.js
```

---

## 4. Connecting the Flutter Mobile App

The Flutter client automatically resolves the backend base URL using `ApiConstants.baseUrl`:
- **Android Emulator**: Resolves to `http://10.0.2.2:3000`
- **macOS / iOS / Web / Tests**: Resolves to `http://localhost:3000`
- **Custom IP / Physical Device**: Supports `--dart-define=API_BASE_URL=http://<IP>:3000`

---

### Option A: macOS Desktop (Recommended for Fast Review)

Runs directly on your Mac with native window rendering and zero emulator overhead:

```bash
# In project root
flutter run -d macos
```

---

### Option B: Android Emulator

Android emulators cannot use `localhost` (which refers to the phone itself). The app automatically maps `http://10.0.2.2:3000` to your host computer's port 3000.

```bash
# 1. Start your Android Emulator in Android Studio or via CLI:
#    emulator -avd Pixel_8_Pro_API_34
# 2. Run the Flutter app:
flutter run -d emulator-5554
```

---

### Option C: Physical Android Device

When running on a real Android phone connected via USB:

#### Method 1: ADB Port Reversal (Most Reliable via USB)
```bash
# 1. Connect Android phone with USB Debugging enabled
# 2. Reverse port 3000 from the device to your computer:
adb reverse tcp:3000 tcp:3000

# 3. Run the app pointing to localhost on the device:
flutter run -d <DEVICE_ID> --dart-define=API_BASE_URL=http://localhost:3000
```

#### Method 2: Local Wi-Fi Network IP
If your computer and phone are connected to the same Wi-Fi network:
```bash
# 1. Find your computer's local LAN IP:
#    macOS: ipconfig getifaddr en0
#    Example: 192.168.1.150

# 2. Run the app with your computer's IP:
flutter run -d <DEVICE_ID> --dart-define=API_BASE_URL=http://192.168.1.150:3000
```

---

### Option D: iOS Simulator

iOS simulators share the host machine's network stack directly:

```bash
flutter run -d iPhone
```

---

### Option E: Chrome Web

```bash
flutter run -d chrome
```

---

## 5. API Endpoint Reference & Verification cURLs

### 1. Health Check
```bash
curl -X GET http://localhost:3000/health
```

### 2. Employee Profile
```bash
curl -X GET http://localhost:3000/employee/me \
  -H "Content-Type: application/json"
```

### 3. Monthly Attendance Register
```bash
curl -X GET "http://localhost:3000/attendance?month=2026-11" \
  -H "Content-Type: application/json"
```

### 4. Check-In Punch (Inside Geofence: 48m away)
```bash
curl -X POST http://localhost:3000/attendance/events \
  -H "Content-Type: application/json" \
  -d '{
    "eventId": "evt-test-checkin-001",
    "eventType": "check_in",
    "timestamp": "2026-11-17T09:00:00.000Z",
    "latitude": 10.6942000,
    "longitude": 76.7348000
  }'
```

### 5. Check-Out Punch
```bash
curl -X POST http://localhost:3000/attendance/events \
  -H "Content-Type: application/json" \
  -d '{
    "eventId": "evt-test-checkout-001",
    "eventType": "check_out",
    "timestamp": "2026-11-17T18:00:00.000Z",
    "latitude": 10.6942000,
    "longitude": 76.7348000
  }'
```

### 6. Geofence Rejection Test (Outside Geofence: 385m away)
```bash
curl -X POST http://localhost:3000/attendance/events \
  -H "Content-Type: application/json" \
  -d '{
    "eventId": "evt-test-outside",
    "eventType": "check_in",
    "timestamp": "2026-11-17T09:00:00.000Z",
    "latitude": 10.6970000,
    "longitude": 76.7370000
  }'
# HTTP 422 Unprocessable: "Attendance rejected: You are 385m from office (>200m limit)."
```

### 7. Leave Balances
```bash
curl -X GET http://localhost:3000/leave/balance \
  -H "Content-Type: application/json"
```

### 8. Submit Leave Request
```bash
curl -X POST http://localhost:3000/leave/requests \
  -H "Content-Type: application/json" \
  -d '{
    "leaveType": "casual",
    "startDate": "2026-11-25",
    "endDate": "2026-11-27",
    "numberOfDays": 3,
    "reason": "Family vacation and travel"
  }'
```

---

## 6. Testing Offline Draining & Auto-Sync

Follow these steps to experience the complete offline-first flow:

1. **Simulate Going Offline**:
   - In the mock API terminal, stop the server with `Ctrl + C`.
2. **Perform Operations in the App**:
   - Open the **Attendance** screen.
   - Tap **Check In**.
   - An offline notification banner will appear indicating: *"Attendance recorded offline. Will sync when online."*
   - Navigate to the **Sync** tab to inspect the pending operation with status `Pending`.
3. **Submit Leave Offline**:
   - Go to **Leave** $\to$ **Apply Leave**.
   - Pick upcoming dates and enter a reason $\ge 10$ characters.
   - Tap **Submit Leave Request**.
   - Notice the leave request is safely stored in the persistent offline queue.
4. **Restore Connectivity**:
   - In the mock API terminal, restart the backend:
     ```bash
     npm start
     ```
5. **Observe Automatic Sync**:
   - Within 15 seconds (or immediately on foreground resume), the app detects API health and automatically drains the queue.
   - In the **Sync** screen, observe the items transition seamlessly from `Pending` $\to$ `Syncing` $\to$ `Synced`.
   - The Attendance and Dashboard screens refresh with confirmed server records.

---

## 7. Simulating Location / Geofence for Reviewers

Reviewers can test all geofencing logic without physically visiting the office:

1. In the app, navigate to the **Attendance** screen.
2. Tap the **`...` (Reviewer GPS Simulator)** popup menu in the top-right corner of the AppBar.
3. Select from the 5 simulation modes:
   - **Inside Office (48m away)**: Enables punch buttons (within the 200m radius).
   - **Outside Office (385m away)**: Disables punch buttons and presents a warning badge indicating the employee is outside the permitted perimeter.
   - **GPS Unavailable**: Simulates disabled device location services.
   - **Permission Denied**: Simulates standard permission rejection.
   - **Permission Permanently Denied**: Simulates "Never Ask Again" with a prompt to open system settings.

---

## 8. Troubleshooting & FAQs

### Q: Port 3000 is already in use (`EADDRINUSE`)
**Fix**: Terminate the previous process occupying port 3000:
```bash
# On macOS / Linux:
lsof -i :3000
# Kill process by PID:
kill -9 <PID>
```
Or start on a custom port:
```bash
PORT=4000 npm start
# In Flutter:
flutter run --dart-define=API_BASE_URL=http://localhost:4000
```

### Q: Android Emulator fails with `SocketException: Connection refused`
**Fix**: Ensure your Flutter code points to `http://10.0.2.2:3000`, not `http://localhost:3000`. This is handled automatically by `ApiConstants.baseUrl`.

### Q: Cleartext HTTP traffic is blocked on Android
**Fix**: `android/app/src/main/AndroidManifest.xml` already includes `android:usesCleartextTraffic="true"`, allowing local HTTP traffic to port 3000 without SSL issues.

### Q: How to reset database records back to fresh seed data?
**Fix**: Replace `mock_api/src/data/database.json` with the seed template or delete it; the server automatically re-initializes fresh seed records upon reboot.

