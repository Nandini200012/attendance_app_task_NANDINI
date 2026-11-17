const http = require('http');
const fs = require('fs');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const config = require('./src/config');

const dbPath = path.join(__dirname, 'src/data/database.json');

function request(method, path, body = null, headers = {}) {
  return new Promise((resolve, reject) => {
    const payload = body ? JSON.stringify(body) : null;
    const reqHeaders = {
      'Content-Type': 'application/json',
      ...headers
    };
    if (payload) {
      reqHeaders['Content-Length'] = Buffer.byteLength(payload);
    }

    const req = http.request(
      {
        hostname: 'localhost',
        port: 3000,
        path,
        method,
        headers: reqHeaders
      },
      (res) => {
        let data = '';
        res.on('data', (chunk) => (data += chunk));
        res.on('end', () => {
          try {
            resolve({
              statusCode: res.statusCode,
              body: data ? JSON.parse(data) : {}
            });
          } catch (e) {
            resolve({
              statusCode: res.statusCode,
              raw: data
            });
          }
        });
      }
    );

    req.on('error', reject);
    if (payload) req.write(payload);
    req.end();
  });
}

async function runTests() {
  console.log('--- Starting Comprehensive REBS HRMS Mock REST API Tests ---');
  let passed = 0;
  let failed = 0;
  const initialSnapshot = fs.readFileSync(dbPath, 'utf8');

  async function test(name, fn) {
    try {
      await fn();
      console.log(`✓ [PASS] ${name}`);
      passed++;
    } catch (err) {
      console.error(`✗ [FAIL] ${name}:`, err.message);
      failed++;
    }
  }

  // 1. Health check
  await test('GET /health returns 200 and StatusCode 6000', async () => {
    const res = await request('GET', '/health');
    if (res.statusCode !== 200) throw new Error(`Expected 200, got ${res.statusCode}`);
    if (res.body.StatusCode !== 6000) throw new Error(`Expected StatusCode 6000, got ${res.body.StatusCode}`);
  });

  // 2. Employee Profile
  await test('GET /employee/me returns employee data with EMP-2048', async () => {
    const res = await request('GET', '/employee/me');
    if (res.statusCode !== 200) throw new Error(`Expected 200, got ${res.statusCode}`);
    if (res.body.data.employee_id !== 'EMP-2048') throw new Error(`Expected EMP-2048, got ${res.body.data.employee_id}`);
    if (!res.body.data.office_location) throw new Error('Missing office location');
  });

  // 3. Employee List
  await test('GET /employee returns 5 seed employees', async () => {
    const res = await request('GET', '/employee');
    if (res.statusCode !== 200) throw new Error(`Expected 200, got ${res.statusCode}`);
    if (res.body.data.length < 5) throw new Error(`Expected at least 5 employees, got ${res.body.data.length}`);
  });

  // 4. Attendance records
  await test('GET /attendance?month=2026-11 returns monthly records', async () => {
    const res = await request('GET', '/attendance?month=2026-11');
    if (res.statusCode !== 200) throw new Error(`Expected 200, got ${res.statusCode}`);
    if (!Array.isArray(res.body.data)) throw new Error('Expected data to be array');
  });

  // 5. Geofence rejection test
  await test('POST /attendance/events outside 200m radius is rejected (422)', async () => {
    const eventId = uuidv4();
    const res = await request('POST', '/attendance/events', {
      event_id: eventId,
      employee_id: 'emp-001',
      event_type: 'check_in',
      timestamp: '2026-11-20T09:00:00.000Z',
      latitude: config.officeLocation.latitude + 0.05, // >5km away
      longitude: config.officeLocation.longitude + 0.05,
      location: 'Outside Office',
      device_info: 'Pixel 8 Pro'
    });
    if (res.statusCode !== 422) throw new Error(`Expected 422 for outside geofence, got ${res.statusCode}`);
    if (res.body.StatusCode !== 6001) throw new Error(`Expected StatusCode 6001, got ${res.body.StatusCode}`);
  });

  // 6. Valid Check-in Event within geofence on a unique test date
  const validCheckInId = uuidv4();
  const testMonth = String(Math.floor(Math.random() * 11) + 1).padStart(2, '0');
  const testDay = String(Math.floor(Math.random() * 25) + 1).padStart(2, '0');
  const testDate = `2027-${testMonth}-${testDay}`;

  await test('POST /attendance/events within 200m radius succeeds (201)', async () => {
    const res = await request('POST', '/attendance/events', {
      event_id: validCheckInId,
      employee_id: 'emp-001',
      event_type: 'check_in',
      timestamp: `${testDate}T09:05:00.000Z`,
      latitude: config.officeLocation.latitude,
      longitude: config.officeLocation.longitude,
      location: config.officeLocation.name,
      device_info: 'Pixel 8 Pro'
    });
    if (res.statusCode !== 201) throw new Error(`Expected 201, got ${res.statusCode}: ${JSON.stringify(res.body)}`);
    if (res.body.data.status !== 'synced') throw new Error(`Expected synced status, got ${res.body.data.status}`);
  });

  // 7. Duplicate event ID check
  await test('POST /attendance/events with duplicate event_id is rejected (409)', async () => {
    const res = await request('POST', '/attendance/events', {
      event_id: validCheckInId, // Reusing existing ID
      employee_id: 'emp-001',
      event_type: 'check_in',
      timestamp: `${testDate}T09:05:00.000Z`,
      latitude: config.officeLocation.latitude,
      longitude: config.officeLocation.longitude
    });
    if (res.statusCode !== 409) throw new Error(`Expected 409 for duplicate event ID, got ${res.statusCode}`);
  });

  // 8. Sequence validation: Already checked in on same date
  await test('POST /attendance/events check-in when already checked in is rejected (422)', async () => {
    const res = await request('POST', '/attendance/events', {
      event_id: uuidv4(),
      employee_id: 'emp-001',
      event_type: 'check_in',
      timestamp: `${testDate}T09:30:00.000Z`,
      latitude: config.officeLocation.latitude,
      longitude: config.officeLocation.longitude
    });
    if (res.statusCode !== 422) throw new Error(`Expected 422 for second check-in, got ${res.statusCode}`);
  });

  // 9. Leave balance retrieval
  await test('GET /leave/balance returns complete quota breakdown', async () => {
    const res = await request('GET', '/leave/balance');
    if (res.statusCode !== 200) throw new Error(`Expected 200, got ${res.statusCode}`);
    if (!res.body.data.leave_type_breakdown.casual) throw new Error('Missing casual leave breakdown');
    if (!res.body.data.leave_type_breakdown.sick) throw new Error('Missing sick leave breakdown');
  });

  // 10. Leave requests retrieval
  await test('GET /leave/requests returns list of past applications', async () => {
    const res = await request('GET', '/leave/requests');
    if (res.statusCode !== 200) throw new Error(`Expected 200, got ${res.statusCode}`);
    if (!Array.isArray(res.body.data)) throw new Error('Expected array of requests');
  });

  // 11. Short reason validation
  await test('POST /leave/requests with reason < 10 chars is rejected (422)', async () => {
    const res = await request('POST', '/leave/requests', {
      leave_type: 'Casual Leave',
      start_date: '2026-12-01',
      end_date: '2026-12-02',
      reason: 'fever'
    });
    if (res.statusCode !== 422) throw new Error(`Expected 422, got ${res.statusCode}`);
  });

  // 12. End date before start date validation
  await test('POST /leave/requests with end_date before start_date is rejected (422)', async () => {
    const res = await request('POST', '/leave/requests', {
      leave_type: 'Casual Leave',
      start_date: '2026-12-05',
      end_date: '2026-12-01',
      reason: 'Vacation planning with family'
    });
    if (res.statusCode !== 422) throw new Error(`Expected 422, got ${res.statusCode}`);
  });

  // 13. Exceeding quota validation
  await test('POST /leave/requests exceeding available balance is rejected (422)', async () => {
    const res = await request('POST', '/leave/requests', {
      leave_type: 'Sick Leave',
      start_date: '2026-12-10',
      end_date: '2026-12-25', // 16 calendar days > 5 available sick days
      reason: 'Extended recovery and physical therapy treatment'
    });
    if (res.statusCode !== 422) throw new Error(`Expected 422 for exceeding quota, got ${res.statusCode}`);
  });

  // 14. Overlapping request rejection
  await test('POST /leave/requests with overlapping dates is rejected (409)', async () => {
    const overlapYear = 2028 + Math.floor(Math.random() * 5);
    const m = String(Math.floor(Math.random() * 11) + 1).padStart(2, '0');
    // Ensure base booking exists
    await request('POST', '/leave/requests', {
      leave_type: 'Casual Leave',
      start_date: `${overlapYear}-${m}-10`,
      end_date: `${overlapYear}-${m}-12`,
      reason: 'Base reservation for milestone vacation'
    });
    // Attempt overlap
    const res = await request('POST', '/leave/requests', {
      leave_type: 'Casual Leave',
      start_date: `${overlapYear}-${m}-11`,
      end_date: `${overlapYear}-${m}-13`,
      reason: 'Overlapping personal vacation request'
    });
    if (res.statusCode !== 409) throw new Error(`Expected 409, got ${res.statusCode}`);
  });

  // 15. Valid leave request creation
  await test('POST /leave/requests valid application creates request (201)', async () => {
    const validYear = 2029 + Math.floor(Math.random() * 5);
    const m = String(Math.floor(Math.random() * 11) + 1).padStart(2, '0');
    const res = await request('POST', '/leave/requests', {
      leave_type: 'Casual Leave',
      start_date: `${validYear}-${m}-01`,
      end_date: `${validYear}-${m}-02`,
      reason: 'Attending annual family milestone event in hometown'
    });
    if (res.statusCode !== 201) throw new Error(`Expected 201, got ${res.statusCode}: ${JSON.stringify(res.body)}`);
    if (res.body.data.request_status !== 'pending') throw new Error(`Expected pending, got ${res.body.data.request_status}`);
  });

  console.log(`\n=======================================================`);
  console.log(` ALL INTEGRATION TESTS PASSED: ${passed}/${passed + failed}`);
  console.log(`=======================================================`);
  try {
    fs.writeFileSync(dbPath, initialSnapshot, 'utf8');
  } catch (_) {}
  process.exit(failed > 0 ? 1 : 0);
}

runTests().catch((err) => {
  console.error('Fatal test runner error:', err);
  process.exit(1);
});
