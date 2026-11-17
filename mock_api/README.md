# REBS HRMS Mock REST API

Fully-featured Node.js + Express mock backend simulating production REST services for the REBS HRMS Employee App.

> **Complete Setup & Testing Guide**: For detailed platform setup instructions (macOS desktop, Android emulator, real device via USB/Wi-Fi, and offline testing), see [MOCK_API_SETUP_INSTRUCTIONS.md](../MOCK_API_SETUP_INSTRUCTIONS.md).

## Quick Start

```bash
cd mock_api
npm install
npm start
```

Runs by default on port `3000`: `http://localhost:3000` (and `http://10.0.2.2:3000` for Android Emulator).

## Endpoints Summary

### 1. Employee
- `GET /employee/me` — Current employee profile (`Nandini N`, `EMP-2048`).
- `GET /employee` — Directory of seed employees.

### 2. Attendance
- `GET /attendance?month=YYYY-MM` — Attendance register for the requested month.
- `POST /attendance/events` — Records a punch event (check-in / check-out) with 200m geofence validation and idempotency.

### 3. Leave Management
- `GET /leave/balance` — Casual and Sick leave allowances and balances.
- `GET /leave/requests` — Employee leave request history.
- `POST /leave/requests` — Submits a new leave application with validation.

### 4. Health
- `GET /health` — API uptime and status check.

## Automated Backend Tests

```bash
node test_api.js
```
