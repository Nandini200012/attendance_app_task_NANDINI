import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_register_app/core/network/api_response.dart';

void main() {
  group('ApiResponse envelope tests', () {
    test('parses StatusCode 6000 as success', () {
      final json = {
        'StatusCode': 6000,
        'message': {'title': 'Success', 'body': 'Data retrieved'},
        'data': {'count': 42},
      };

      final response = ApiResponse<Map<String, dynamic>>.fromJson(
        json,
        (raw) => Map<String, dynamic>.from(raw as Map),
      );

      expect(response.isSuccess, isTrue);
      expect(response.statusCode, 6000);
      expect(response.title, 'Success');
      expect(response.message, 'Data retrieved');
      expect(response.data?['count'], 42);
    });

    test('parses StatusCode 6001 as error', () {
      final json = {
        'StatusCode': 6001,
        'message': {'title': 'Error', 'body': 'Validation failed'},
        'data': null,
      };

      final response = ApiResponse<dynamic>.fromJson(json, null);

      expect(response.isSuccess, isFalse);
      expect(response.statusCode, 6001);
      expect(response.title, 'Error');
      expect(response.message, 'Validation failed');
      expect(response.data, isNull);
    });
  });
}
