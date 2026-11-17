# REBS HRMS — REST API Documentation

Comprehensive technical documentation for the REBS HRMS Mock REST API and its integration with the Flutter Employee Application.

---

## 1. Overview & Architecture

### Base URLs
- **Localhost / Desktop / iOS Simulator**: `http://localhost:3000`
- **Android Emulator**: `http://10.0.2.2:3000`
- **Production / Staging**: *Planned (Not yet deployed)*

### Protocol & Format
- **Protocol**: HTTP/1.1
- **Data Interchange Format**: JSON (`application/json`)
- **Character Encoding**: UTF-8

### Response Envelope Standard
Every endpoint in the REBS HRMS API adheres to a strict, standardized JSON envelope:

#### Successful Response Envelope (`StatusCode: 6000`)
```json
{
  "StatusCode": 6000,
  "message": {
    "title": "Success",
    "body": "Detailed success explanation"
  },
  "data": { ... }
}
```

#### Error Response Envelope (`StatusCode: 6001`)
```json
{
  "StatusCode": 6001,
  "message": {
    "title": "Error Title",
    "body": "Detailed failure or validation error message"
  },
  "data": null
}
```

---

## 2. Global Headers & Authentication

| Header Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `Content-Type` | String | Required for POST | Must be `application/json` |
| `Accept` | String | Recommended | Must be `application/json` |
| `x-employee-id` | String | Optional | Identifies the requesting employee. Defaults to `emp-001` (`Nandini N`, `EMP-2048`) if omitted. |

> **Authentication Status Note**:
> - **Implemented**: Header-based identification (`x-employee-id` header or body fallback).
> - **Planned / Incomplete**: Bearer JWT / OAuth2 token exchange is planned for future enterprise SSO integration and is not implemented in the mock API.

---

## 3. Implemented vs. Planned Endpoints Summary

### Implemented Endpoints
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/health` | Server uptime and health verification |
| `GET` | `/employee/me` | Fetch authenticated employee profile |
| `GET` | `/employee` | List all 5 seed employees in directory |
| `GET` | `/attendance` | Query monthly attendance records with summary |
| `POST` | `/attendance/events` | Record attendance punch with geofence validation |
| `GET` | `/leave/balance` | Query casual & sick leave quotas and pending days |
| `GET` | `/leave/requests` | List past and active leave applications |
| `POST` | `/leave/requests` | Submit new leave application with validation |

### Planned / Not Implemented Endpoints
The following endpoints and HTTP methods are **NOT implemented** in the mock API:
- `PUT /attendance/events/:id` (Attendance correction workflow)
- `DELETE /leave/requests/:id` (Leave cancellation workflow)
- `PATCH /employee/me` (Profile detail update)
- `POST /auth/login` (Token authentication)

---

## 4. Endpoint Specifications

### 4.1 System & Health

#### `GET /health`
Checks server availability and process uptime.

- **URL**: `http://localhost:3000/health`
- **Method**: `GET`
- **Headers**: None required.
- **Request Body**: None.
- **Query Parameters**: None.

##### Response Example (200 OK)
```json
{
  "StatusCode": 6000,
  "message": {
    "title": "Healthy",
    "body": "REBS HRMS Mock REST API is online."
  },
  "data": {
    "uptime": 142.56,
    "timestamp": "2026-11-16T15:15:00.000Z"
  }
}
```

---

### 4.2 Employee Management

#### `GET /employee/me`
Retrieves detailed profile metadata for the authenticated employee.

- **URL**: `http://localhost:3000/employee/me`
- **Method**: `GET`
- **Headers**:
  - `x-employee-id` *(optional, string, default: "emp-001")*
- **Query Parameters**: None.
- **Request Body**: None.

##### Response Example (200 OK)
```json
{
  "StatusCode": 6000,
  "message": {
    "title": "Employee Profile",
    "body": "Employee profile retrieved successfully"
  },
  "data": {
    "id": "emp-001",
    "employee_id": "EMP-2048",
    "employee_name": "Nandini N",
    "profile_image": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=250",
    "designation": "Senior Flutter Specialist",
    "department": "Mobile Engineering",
    "email": "nandini.n@rebs.io",
    "phone_number": "+91 98765 43210",
    "office_location": "REBS HQ (Bangalore Tech Park)",
    "employee_status": "Active"
  }
}
```

##### Error Example (404 Not Found)
When `x-employee-id` does not match any existing record:
```json
{
  "StatusCode": 6001,
  "message": {
    "title": "Employee Not Found",
    "body": "Employee with ID 'emp-999' was not found."
  },
  "data": null
}
```

---

#### `GET /employee`
Retrieves the full employee directory (at least 5 realistic Indian employee records).

- **URL**: `http://localhost:3000/employee`
- **Method**: `GET`
- **Headers**: None required.
- **Query Parameters**: None.
- **Request Body**: None.

##### Response Example (200 OK)
```json
{
  "StatusCode": 6000,
  "message": {
    "title": "Employees List",
    "body": "All employees retrieved successfully"
  },
  "data": [
    {
      "id": "emp-001",
      "employee_id": "EMP-2048",
      "employee_name": "Nandini N",
      "designation": "Senior Flutter Specialist",
      "department": "Mobile Engineering",
      "email": "nandini.n@rebs.io",
      "phone_number": "+91 98765 43210",
      "office_location": "REBS HQ (Bangalore Tech Park)",
      "employee_status": "Active"
    },
    {
      "id": "emp-002",
      "employee_id": "EMP-2049",
      "employee_name": "Aarav Sharma",
      "designation": "Backend Tech Lead",
      "department": "Cloud Infrastructure",
      "email": "aarav.sharma@rebs.io",
      "phone_number": "+91 98765 43211",
      "office_location": "REBS HQ (Bangalore Tech Park)",
      "employee_status": "Active"
    },
    {
      "id": "emp-003",
      "employee_id": "EMP-2050",
      "employee_name": "Priya Patel",
      "designation": "Product Designer",
      "department": "UI/UX Design",
      "email": "priya.patel@rebs.io",
      "phone_number": "+91 98765 43212",
      "office_location": "REBS HQ (Bangalore Tech Park)",
      "employee_status": "Active"
    },
    {
      "id": "emp-004",
      "employee_id": "EMP-2051",
      "employee_name": "Rajesh Kumar",
      "designation": "QA Automation Engineer",
      "department": "Quality Engineering",
      "email": "rajesh.kumar@rebs.io",
      "phone_number": "+91 98765 43213",
      "office_location": "REBS HQ (Bangalore Tech Park)",
      "employee_status": "Active"
    },
    {
      "id": "emp-005",
      "employee_id": "EMP-2052",
      "employee_name": "Sneha Reddy",
      "designation": "HR Business Partner",
      "department": "People Operations",
      "email": "sneha.reddy@rebs.io",
      "phone_number": "+91 98765 43214",
      "office_location": "REBS HQ (Bangalore Tech Park)",
      "employee_status": "Active"
    }
  ]
}
```

---

### 4.3 Attendance Management

#### `GET /attendance`
Queries daily consolidated attendance records for an employee, optionally filtered by month.

- **URL**: `http://localhost:3000/attendance`
- **Method**: `GET`
- **Headers**:
  - `x-employee-id` *(optional, string, default: "emp-001")*
- **Query Parameters**:
  - `month` *(optional, string, format: `YYYY-MM`, e.g. `2026-11`)*

##### Response Example (200 OK)
```json
{
  "StatusCode": 6000,
  "message": {
    "title": "Attendance Records",
    "body": "Retrieved 12 records successfully"
  },
  "data": [
    {
      "id": "REC-2026-1116",
      "employee_id": "emp-001",
      "attendance_date": "2026-11-16",
      "check_in_time": "2026-11-16T09:15:30.000Z",
      "check_out_time": "2026-11-16T14:15:00.000Z",
      "working_hours": "4h 59m",
      "attendance_status": "Checked Out",
      "location": "REBS HQ (48m from perimeter)",
      "sync_status": "Synced"
    },
    {
      "id": "REC-2026-1115",
      "employee_id": "emp-001",
      "attendance_date": "2026-11-15",
      "check_in_time": "2026-11-15T09:02:14.000Z",
      "check_out_time": "2026-11-15T18:15:20.000Z",
      "working_hours": "9h 13m",
      "attendance_status": "Checked Out",
      "location": "REBS HQ (52m from perimeter)",
      "sync_status": "Synced"
    }
  ]
}
```

---

#### `POST /attendance/events`
Processes and records an individual attendance punch (`check_in` or `check_out`), performing geofencing, duplicate prevention, and sequence validation.

- **URL**: `http://localhost:3000/attendance/events`
- **Method**: `POST`
- **Headers**:
  - `Content-Type: application/json`
  - `x-employee-id` *(optional, string, default: "emp-001")*

##### Request Body Parameters
| Field | Type | Required | Description | Example |
| :--- | :--- | :--- | :--- | :--- |
| `event_id` | String | **Yes** | Client-generated UUID for deduplication | `"evt-550e8400-e29b-41d4-a716-446655440000"` |
| `employee_id` | String | **Yes** | Target employee identifier | `"emp-001"` |
| `event_type` | String | **Yes** | Punch action: `"check_in"` or `"check_out"` | `"check_in"` |
| `timestamp` | String | **Yes** | ISO-8601 UTC timestamp of punch | `"2026-11-16T09:15:30.000Z"` |
| `latitude` | Number | Optional | GPS latitude reading | `12.971598` |
| `longitude` | Number | Optional | GPS longitude reading | `77.594562` |
| `location` | String | Optional | Descriptive location string | `"REBS Bangalore HQ"` |
| `device_info` | String/Obj | Optional | Mobile telemetry metadata | `"Pixel 8 Pro (Android 14)"` |

##### Request Body Example
```json
{
  "event_id": "evt-7a8b9c0d-1116-4abc-9999-abcdef123456",
  "employee_id": "emp-001",
  "event_type": "check_in",
  "timestamp": "2026-11-16T09:15:30.000Z",
  "latitude": 12.971612,
  "longitude": 77.594589,
  "location": "REBS HQ Entrance",
  "device_info": "Pixel 8 Pro (Android 14)"
}
```

##### Successful Check-in Response Example (201 Created)
```json
{
  "StatusCode": 6000,
  "message": {
    "title": "Attendance Event Synced",
    "body": "Attendance check in recorded successfully."
  },
  "data": {
    "event_id": "evt-7a8b9c0d-1116-4abc-9999-abcdef123456",
    "status": "synced",
    "server_timestamp": "2026-11-16T09:15:31.102Z",
    "distance_meters": 48.2,
    "rejection_reason": null,
    "message": "Attendance check in recorded successfully."
  }
}
```

##### Geofence Rejection Response Example (422 Unprocessable Entity)
Triggered when device coordinates are outside the `200.0m` office perimeter ($distance > 200.0\text{m}$):
```json
{
  "StatusCode": 6001,
  "message": {
    "title": "Attendance Rejected",
    "body": "Outside allowed geofence perimeter (468.5m > 200m limit)."
  },
  "data": null
}
```

##### Duplicate Event ID Error Example (409 Conflict)
```json
{
  "StatusCode": 6001,
  "message": {
    "title": "Event Validation Failed",
    "body": "Duplicate event detected. Event with ID 'evt-7a8b9c0d-1116-4abc-9999-abcdef123456' has already been processed."
  },
  "data": null
}
```

##### Sequence Validation Error Examples (422 Unprocessable Entity)
1. **Double Check-in**:
   ```json
   {
     "StatusCode": 6001,
     "message": {
       "title": "Event Validation Failed",
       "body": "Employee is already checked in for date 2026-11-16."
     },
     "data": null
   }
   ```
2. **Check-out without Check-in**:
   ```json
   {
     "StatusCode": 6001,
     "message": {
       "title": "Event Validation Failed",
       "body": "Cannot check out without an active check-in for date 2026-11-16."
     },
     "data": null
   }
   ```
3. **Double Check-out**:
   ```json
   {
     "StatusCode": 6001,
     "message": {
       "title": "Event Validation Failed",
       "body": "Employee is already checked out for date 2026-11-16."
     },
     "data": null
   }
   ```

---

### 4.4 Leave Management

#### `GET /leave/balance`
Retrieves employee leave allowances, utilized counts, available quotas, and pending days.

- **URL**: `http://localhost:3000/leave/balance`
- **Method**: `GET`
- **Headers**:
  - `x-employee-id` *(optional, string, default: "emp-001")*
- **Request Body**: None.

##### Response Example (200 OK)
```json
{
  "StatusCode": 6000,
  "message": {
    "title": "Leave Balance",
    "body": "Leave balance retrieved successfully"
  },
  "data": {
    "total_leave": 22,
    "used_leave": 9,
    "available_leave": 11,
    "pending_leave": 5,
    "leave_type_breakdown": {
      "casual": {
        "total": 12,
        "used": 4,
        "available": 6,
        "pending": 5
      },
      "sick": {
        "total": 10,
        "used": 5,
        "available": 5,
        "pending": 0
      }
    }
  }
}
```

---

#### `GET /leave/requests`
Retrieves the application history of all submitted leave requests for the employee.

- **URL**: `http://localhost:3000/leave/requests`
- **Method**: `GET`
- **Headers**:
  - `x-employee-id` *(optional, string, default: "emp-001")*
- **Request Body**: None.

##### Response Example (200 OK)
```json
{
  "StatusCode": 6000,
  "message": {
    "title": "Leave Requests",
    "body": "Retrieved 4 leave requests"
  },
  "data": [
    {
      "request_id": "LEV-2026-004",
      "employee_id": "emp-001",
      "leave_type": "Casual Leave",
      "start_date": "2026-11-24",
      "end_date": "2026-11-26",
      "number_of_days": 3,
      "reason": "Attending annual family gathering and personal travel.",
      "request_status": "pending",
      "applied_date": "2026-11-14",
      "rejection_reason": null
    },
    {
      "request_id": "LEV-2026-003",
      "employee_id": "emp-001",
      "leave_type": "Sick Leave",
      "start_date": "2026-11-04",
      "end_date": "2026-11-05",
      "number_of_days": 2,
      "reason": "Severe seasonal flu and prescribed medical bed rest.",
      "request_status": "approved",
      "applied_date": "2026-11-03",
      "rejection_reason": null
    }
  ]
}
```

---

#### `POST /leave/requests`
Validates and submits a new employee leave request. Automatically deducts the requested duration from `available_leave` and increments `pending_leave`.

- **URL**: `http://localhost:3000/leave/requests`
- **Method**: `POST`
- **Headers**:
  - `Content-Type: application/json`
  - `x-employee-id` *(optional, string, default: "emp-001")*

##### Request Body Parameters
| Field | Type | Required | Description | Example |
| :--- | :--- | :--- | :--- | :--- |
| `leave_type` | String | **Yes** | `"Casual Leave"` or `"Sick Leave"` | `"Casual Leave"` |
| `start_date` | String | **Yes** | Starting date in `YYYY-MM-DD` | `"2026-12-05"` |
| `end_date` | String | **Yes** | Ending date in `YYYY-MM-DD` | `"2026-12-07"` |
| `number_of_days` | Number | Optional | Calendar days (auto-computed if omitted) | `3` |
| `reason` | String | **Yes** | Justification ($\ge 10$ non-whitespace chars) | `"Attending sister's wedding ceremony"` |

##### Request Body Example
```json
{
  "leave_type": "Casual Leave",
  "start_date": "2026-12-05",
  "end_date": "2026-12-07",
  "number_of_days": 3,
  "reason": "Attending sister's wedding ceremony and family celebrations"
}
```

##### Successful Creation Response Example (201 Created)
```json
{
  "StatusCode": 6000,
  "message": {
    "title": "Leave Application Submitted",
    "body": "Leave application queued successfully"
  },
  "data": {
    "request_id": "LEV-481920",
    "employee_id": "emp-001",
    "leave_type": "Casual Leave",
    "start_date": "2026-12-05",
    "end_date": "2026-12-07",
    "number_of_days": 3,
    "reason": "Attending sister's wedding ceremony and family celebrations",
    "request_status": "pending",
    "applied_date": "2026-11-16",
    "rejection_reason": null
  }
}
```

##### Leave Validation Error Examples
1. **Reason Shorter than 10 Non-Whitespace Characters (422 Unprocessable Entity)**:
   ```json
   {
     "StatusCode": 6001,
     "message": {
       "title": "Validation Failed",
       "body": "Reason must contain at least 10 non-whitespace characters."
     },
     "data": null
   }
   ```
2. **Inverted Dates ($end\_date < start\_date$) (422 Unprocessable Entity)**:
   ```json
   {
     "StatusCode": 6001,
     "message": {
       "title": "Validation Failed",
       "body": "End date cannot be earlier than start date."
     },
     "data": null
   }
   ```
3. **Insufficient Available Leave Balance (422 Unprocessable Entity)**:
   ```json
   {
     "StatusCode": 6001,
     "message": {
       "title": "Validation Failed",
       "body": "Insufficient leave balance. Requested 15 days exceeds available 6 days."
     },
     "data": null
   }
   ```
4. **Overlapping Existing Leave Request (409 Conflict)**:
   ```json
   {
     "StatusCode": 6001,
     "message": {
       "title": "Validation Failed",
       "body": "Overlapping leave request exists for the selected date range."
     },
     "data": null
   }
   ```

---

## 5. Attendance & Geofence Business Rules

### 5.1 Geofence Perimeter Verification
- **Office Target Latitude**: `12.971598`
- **Office Target Longitude**: `77.594562`
- **Maximum Allowed Radius**: `200.0 metres`
- **Distance Formula**: Haversine Spherical Model
  $$d = 2r \arcsin\left(\sqrt{\sin^2\left(\frac{\Delta \varphi}{2}\right) + \cos(\varphi_1)\cos(\varphi_2)\sin^2\left(\frac{\Delta \lambda}{2}\right)}\right)$$
  *(where $r = 6,371,000\text{ m}$)*
- **Outcome**:
  - If $d \le 200.0\text{ m}$: Event status is set to `'synced'`, consolidates the daily attendance record, and returns HTTP `201`.
  - If $d > 200.0\text{m}$: Event status is set to `'rejected'`, logs diagnostic rejection in the database, and returns HTTP `422`.

### 5.2 Deduplication & Idempotency
- Each punch must supply a unique `event_id` (UUIDv4).
- If an event with the same `event_id` exists in the database, the server rejects it with HTTP `409 Conflict`.

### 5.3 Daily Sequence Integrity
1. **Check-In**: Only 1 check-in is permitted per employee per calendar date. Subsequent check-ins trigger HTTP `422`.
2. **Check-Out**: Requires an existing active check-in on the same date. Cannot check out without a check-in.
3. **Repeated Check-Out**: Only 1 check-out is permitted per calendar date. Subsequent check-outs trigger HTTP `422`.

### 5.4 Offline Event Syncing (Flutter Hive Layer)
- When the device is offline or API calls fail with network timeouts:
  1. The Flutter client creates an `AttendanceEvent` with status `'pending'`.
  2. The event is persisted locally to Hive box `rebs_pending_events`.
  3. When connectivity returns or the user taps **"Sync Now"**:
     - `SyncRepository.syncPendingEvents()` drains the queue by POSTing each event to `/attendance/events`.
     - Confirmed events are moved to `rebs_synced_events`.
     - Rejected events are moved to `rebs_rejected_events` along with the server diagnostic rejection string.

---

## 6. Database Models & Schema Relationships

The mock persistence layer (`mock_api/src/data/database.json`) models 5 core entities:

```
[Employee] (id, employee_id)
    │
    ├── 1:1 ──► [LeaveBalance] (total, used, available, pending)
    │
    ├── 1:N ──► [LeaveRequest] (request_id, employee_id, leave_type, dates, status)
    │
    ├── 1:N ──► [AttendanceRecord] (id, employee_id, attendance_date, hours, status)
    │
    └── 1:N ──► [AttendanceEvent] (event_id, employee_id, event_type, telemetry, status)
```

### Entity Fields

#### `Employee`
- `id`: Primary internal key (e.g. `"emp-001"`)
- `employee_id`: Corporate code (e.g. `"EMP-2048"`)
- `employee_name`: Full name
- `designation`: Job role title
- `department`: Business unit
- `email`: Corporate email address
- `phone_number`: Contact mobile number
- `office_location`: Name of assigned base office
- `employee_status`: Employment state (`"Active"`)

#### `AttendanceRecord`
- `id`: Consolidated record key (e.g. `"REC-2026-1116"`)
- `employee_id`: Foreign key reference to Employee
- `attendance_date`: Date string `YYYY-MM-DD`
- `check_in_time`: ISO-8601 timestamp of first check-in
- `check_out_time`: ISO-8601 timestamp of final check-out (or null)
- `working_hours`: Calculated duration string (e.g. `"8h 30m"`)
- `attendance_status`: Current state (`"Checked In"`, `"Checked Out"`)
- `location`: Geofence description string
- `sync_status`: Cloud sync status (`"Synced"`, `"Pending"`)

#### `AttendanceEvent`
- `event_id`: UUIDv4 unique transaction key
- `employee_id`: Foreign key reference to Employee
- `event_type`: `"check_in"` or `"check_out"`
- `timestamp`: Device timestamp in ISO-8601
- `latitude` / `longitude`: Floating point GPS coordinates
- `distance_meters`: Calculated distance from HQ
- `sync_status`: `"synced"`, `"pending"`, or `"rejected"`
- `rejection_reason`: Diagnostic explanation if rejected
- `device_info`: Hardware telemetry string

#### `LeaveBalance`
- `total_leave`: Total allocated days across all types
- `used_leave`: Consumed days
- `available_leave`: Remaining balance available to apply
- `pending_leave`: Days reserved in pending applications
- `leave_type_breakdown`: Keyed by leave type (`casual`, `sick`), each tracking `total`, `used`, `available`, and `pending`

#### `LeaveRequest`
- `request_id`: Application key (e.g. `"LEV-2026-004"`)
- `employee_id`: Foreign key reference to Employee
- `leave_type`: `"Casual Leave"` or `"Sick Leave"`
- `start_date` / `end_date`: Inclusive date boundaries
- `number_of_days`: Duration in calendar days
- `reason`: Justification text
- `request_status`: `"pending"`, `"approved"`, or `"rejected"`
- `applied_date`: Submission date
- `rejection_reason`: Explanation from approver (if rejected)

---

## 7. Postman & cURL Testing Instructions

### Setting Up Postman
1. Create a new Collection named **`REBS HRMS Mock API`**.
2. Add a Collection Variable:
   - `baseUrl` = `http://localhost:3000`
3. In Collection Headers, add:
   - `Content-Type`: `application/json`
   - `Accept`: `application/json`
   - `x-employee-id`: `emp-001`

---

### Test Cases & cURL Commands

#### 1. System Health Check
```bash
curl -X GET "http://localhost:3000/health" \
     -H "Accept: application/json"
```

#### 2. Get Authenticated Employee Profile
```bash
curl -X GET "http://localhost:3000/employee/me" \
     -H "x-employee-id: emp-001" \
     -H "Accept: application/json"
```

#### 3. Get Employee Directory
```bash
curl -X GET "http://localhost:3000/employee" \
     -H "Accept: application/json"
```

#### 4. Query Monthly Attendance (November 2026)
```bash
curl -X GET "http://localhost:3000/attendance?month=2026-11" \
     -H "x-employee-id: emp-001" \
     -H "Accept: application/json"
```

#### 5. Submit Valid Check-in Punch (Within 200m)
```bash
curl -X POST "http://localhost:3000/attendance/events" \
     -H "Content-Type: application/json" \
     -H "x-employee-id: emp-001" \
     -d '{
       "event_id": "evt-test-'$(date +%s)'",
       "employee_id": "emp-001",
       "event_type": "check_in",
       "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",
       "latitude": 12.971612,
       "longitude": 77.594589,
       "location": "HQ Entrance",
       "device_info": "Postman Test Runner"
     }'
```

#### 6. Submit Out-of-Radius Check-in Punch (Should return 422 Rejection)
```bash
curl -X POST "http://localhost:3000/attendance/events" \
     -H "Content-Type: application/json" \
     -H "x-employee-id: emp-001" \
     -d '{
       "event_id": "evt-out-of-bounds-'$(date +%s)'",
       "employee_id": "emp-001",
       "event_type": "check_in",
       "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",
       "latitude": 12.975210,
       "longitude": 77.598420,
       "location": "500m Away from HQ",
       "device_info": "Postman Test Runner"
     }'
```

#### 7. Get Leave Balance
```bash
curl -X GET "http://localhost:3000/leave/balance" \
     -H "x-employee-id: emp-001" \
     -H "Accept: application/json"
```

#### 8. Get Leave Requests History
```bash
curl -X GET "http://localhost:3000/leave/requests" \
     -H "x-employee-id: emp-001" \
     -H "Accept: application/json"
```

#### 9. Submit Valid Leave Application
```bash
curl -X POST "http://localhost:3000/leave/requests" \
     -H "Content-Type: application/json" \
     -H "x-employee-id: emp-001" \
     -d '{
       "leave_type": "Casual Leave",
       "start_date": "2026-12-10",
       "end_date": "2026-12-11",
       "number_of_days": 2,
       "reason": "Personal family wedding ceremony attendance in home town"
     }'
```

#### 10. Submit Invalid Leave Application (Reason too short, Should return 422)
```bash
curl -X POST "http://localhost:3000/leave/requests" \
     -H "Content-Type: application/json" \
     -H "x-employee-id: emp-001" \
     -d '{
       "leave_type": "Casual Leave",
       "start_date": "2026-12-15",
       "end_date": "2026-12-16",
       "number_of_days": 2,
       "reason": "Sick"
     }'
```

