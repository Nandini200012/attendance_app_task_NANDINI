import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import 'api_response.dart';
import 'network_logger.dart';

/// Reusable HTTP client for communicating with the REBS HRMS REST backend.
class ApiClient {
  final http.Client _client;
  final String _baseUrl;

  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConstants.baseUrl;

  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$_baseUrl$cleanPath').replace(
      queryParameters: queryParams?.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  /// Sends a GET request and deserializes the JSON response envelope.
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    T Function(dynamic rawData)? fromData,
  }) async {
    final uri = _buildUri(path, queryParams);
    NetworkLogger.logRequest(method: 'GET', uri: uri, queryParams: queryParams);
    try {
      final response = await _client
          .get(uri, headers: {..._defaultHeaders, ...?headers})
          .timeout(ApiConstants.connectionTimeout);

      NetworkLogger.logResponse(
        method: 'GET',
        uri: uri,
        statusCode: response.statusCode,
        responseBody: response.body,
      );
      return _processResponse<T>(response, fromData);
    } catch (e) {
      throw _handleError('GET', uri, e);
    }
  }

  /// Sends a POST request and deserializes the JSON response envelope.
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    T Function(dynamic rawData)? fromData,
  }) async {
    final uri = _buildUri(path);
    final encodedBody = body != null ? jsonEncode(body) : null;
    NetworkLogger.logRequest(method: 'POST', uri: uri, body: body);

    try {
      final response = await _client
          .post(
            uri,
            headers: {..._defaultHeaders, ...?headers},
            body: encodedBody,
          )
          .timeout(ApiConstants.connectionTimeout);

      NetworkLogger.logResponse(
        method: 'POST',
        uri: uri,
        statusCode: response.statusCode,
        responseBody: response.body,
      );
      return _processResponse<T>(response, fromData);
    } catch (e) {
      throw _handleError('POST', uri, e);
    }
  }

  /// Verifies if the backend server is reachable.
  Future<bool> checkConnectivity() async {
    try {
      final uri = _buildUri(ApiConstants.health);
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Exception _handleError(String method, Uri uri, Object error) {
    NetworkLogger.logError(method: method, uri: uri, error: error);
    if (error is SocketException) {
      return NetworkException('Unable to reach server: ${error.message}');
    }
    if (error is TimeoutException) {
      return const NetworkException('Request timed out. Please try again.');
    }
    return error is Exception ? error : Exception(error.toString());
  }

  ApiResponse<T> _processResponse<T>(
    http.Response response,
    T Function(dynamic rawData)? fromData,
  ) {
    try {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final envelope = ApiResponse<T>.fromJson(json, fromData);

      if (!envelope.isSuccess && response.statusCode >= 400) {
        throw ServerException(
          message: envelope.message.isNotEmpty
              ? envelope.message
              : 'Server returned code ${response.statusCode}',
          statusCode: envelope.statusCode,
        );
      }
      return envelope;
    } on FormatException {
      throw ServerException(
        message: 'Invalid response received from server',
        statusCode: response.statusCode,
      );
    }
  }
}
