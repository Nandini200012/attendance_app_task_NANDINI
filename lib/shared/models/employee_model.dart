/// Data model representing an employee's profile in REBS HRMS.
class EmployeeModel {
  final String id;
  final String name;
  final String employeeCode;
  final String department;
  final String designation;
  final String email;
  final String? profileImage;
  final String? phone;
  final String? officeLocationName;
  final double? officeLatitude;
  final double? officeLongitude;
  final double? officeRadius;
  final String? status;

  const EmployeeModel({
    required this.id,
    required this.name,
    required this.employeeCode,
    required this.department,
    required this.designation,
    required this.email,
    this.profileImage,
    this.phone,
    this.officeLocationName,
    this.officeLatitude,
    this.officeLongitude,
    this.officeRadius,
    this.status,
  });

  /// Factory constructor to deserialize from API response JSON.
  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    final office = json['officeLocation'];
    final officeName = office is Map<String, dynamic>
        ? office['name'] as String?
        : (json['office_location'] as String? ?? office as String?);
    final officeLat = office is Map<String, dynamic>
        ? (office['latitude'] as num?)?.toDouble()
        : null;
    final officeLng = office is Map<String, dynamic>
        ? (office['longitude'] as num?)?.toDouble()
        : null;
    final officeRad = office is Map<String, dynamic>
        ? (office['allowedRadiusMeters'] as num?)?.toDouble()
        : null;

    return EmployeeModel(
      id: json['id'] as String? ?? json['employeeId'] as String? ?? '',
      name:
          json['employee_name'] as String? ??
          json['name'] as String? ??
          '',
      employeeCode:
          json['employee_id'] as String? ??
          json['employeeCode'] as String? ??
          '',
      department: json['department'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profileImage:
          json['profile_image'] as String? ?? json['profileImage'] as String?,
      phone: json['phone_number'] as String? ?? json['phone'] as String?,
      officeLocationName: officeName,
      officeLatitude: officeLat,
      officeLongitude: officeLng,
      officeRadius: officeRad,
      status: json['employee_status'] as String? ?? json['status'] as String?,
    );
  }

  /// Serializes instance to JSON map for local cache storage.
  Map<String, dynamic> toJson() => {
    'id': id,
    'employeeId': id,
    'employee_id': employeeCode,
    'employeeCode': employeeCode,
    'name': name,
    'employee_name': name,
    'department': department,
    'designation': designation,
    'email': email,
    'profile_image': profileImage,
    'profileImage': profileImage,
    'phone_number': phone,
    'phone': phone,
    'office_location': officeLocationName,
    'officeLocation': {
      'name': officeLocationName,
      'latitude': officeLatitude,
      'longitude': officeLongitude,
      'allowedRadiusMeters': officeRadius,
    },
    'employee_status': status,
    'status': status,
  };

  /// Standard placeholder employee data for UI demonstration.
  static const EmployeeModel mockEmployee = EmployeeModel(
    id: 'emp-001',
    name: 'Nandini N',
    employeeCode: 'EMP-2048',
    department: 'Mobile Engineering',
    designation: 'Senior Flutter Specialist',
    email: 'nandini.n@rebs.io',
  );
}
