import 'dart:convert';

/// Lightweight value object for a queued HTTP write operation.
///
/// Auth tokens are intentionally excluded. Replay attaches fresh credentials.
class QueuedRequest {
  const QueuedRequest({
    required this.method,
    required this.path,
    this.body,
    required this.timestamp,
    this.retryCount = 0,
  });

  final String method;
  final String path;

  /// JSON-encodable request body. Must not contain auth headers or tokens.
  final Map<String, dynamic>? body;
  final DateTime timestamp;
  final int retryCount;

  Map<String, dynamic> toMap() => {
    'method': method,
    'path': path,
    'body': body,
    'timestamp': timestamp.toIso8601String(),
    'retryCount': retryCount,
  };

  factory QueuedRequest.fromMap(Map<dynamic, dynamic> map) => QueuedRequest(
    method: map['method'] as String,
    path: map['path'] as String,
    body: map['body'] != null
        ? Map<String, dynamic>.from(map['body'] as Map)
        : null,
    timestamp: DateTime.parse(map['timestamp'] as String),
    retryCount: (map['retryCount'] as int?) ?? 0,
  );

  factory QueuedRequest.fromJsonString(String value) =>
      QueuedRequest.fromMap(jsonDecode(value) as Map<dynamic, dynamic>);

  String toJsonString() => jsonEncode(toMap());

  QueuedRequest copyWith({int? retryCount}) => QueuedRequest(
    method: method,
    path: path,
    body: body,
    timestamp: timestamp,
    retryCount: retryCount ?? this.retryCount,
  );
}
