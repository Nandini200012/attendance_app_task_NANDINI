/// Envelope encapsulating standard REBS HRMS REST API responses.
class ApiResponse<T> {
  final int statusCode;
  final String title;
  final String message;
  final T? data;

  const ApiResponse({
    required this.statusCode,
    required this.title,
    required this.message,
    this.data,
  });

  /// Indicates whether the response is considered successful (StatusCode 6000).
  bool get isSuccess => statusCode == 6000;

  /// Factory parser for standard response envelopes.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic rawData)? fromData,
  ) {
    final status = json['StatusCode'] as int? ?? 6001;
    final rawMsg = json['message'];
    String title = '';
    String body = '';
    if (rawMsg is Map) {
      title = rawMsg['title'] as String? ?? '';
      body = rawMsg['body'] as String? ?? '';
    } else if (rawMsg is String) {
      body = rawMsg;
    }
    final rawData = json['data'];

    T? parsedData;
    if (rawData != null && fromData != null) {
      parsedData = fromData(rawData);
    }

    return ApiResponse<T>(
      statusCode: status,
      title: title,
      message: body,
      data: parsedData,
    );
  }
}
