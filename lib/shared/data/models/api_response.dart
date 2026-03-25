/// Generic API response envelope used across all endpoints.
class ApiResponse<T> {
  const ApiResponse({
    required this.statusCode,
    this.data,
    this.message,
    this.errors,
  });

  final T? data;
  final String? message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  /// True when status code is 2xx.
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
    int statusCode,
  ) {
    return ApiResponse<T>(
      statusCode: statusCode,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      message: json['message'] as String?,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  ApiResponse<T> copyWith({
    T? data,
    String? message,
    int? statusCode,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse<T>(
      data: data ?? this.data,
      message: message ?? this.message,
      statusCode: statusCode ?? this.statusCode,
      errors: errors ?? this.errors,
    );
  }

  @override
  String toString() =>
      'ApiResponse(statusCode: $statusCode, isSuccess: $isSuccess, message: $message)';
}
