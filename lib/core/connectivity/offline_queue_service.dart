import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../auth/token_manager.dart';
import 'connectivity_cubit.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const _boxName = 'offline_queue';
const _maxQueueSize = 100;
const _maxRetries = 3;
const _maxAgeHours = 24;

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

/// Lightweight value object for a queued HTTP write operation.
///
/// Auth tokens are intentionally excluded — they are re-attached fresh from
/// [TokenManager] at replay time to avoid storing credentials on disk.
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

  /// JSON-encodable request body. Must NOT contain auth headers or tokens.
  final Map<String, dynamic>? body;
  final DateTime timestamp;
  final int retryCount;

  // ---- Hive serialization (manual, avoids code-gen dependency) --------------

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

  QueuedRequest copyWith({int? retryCount}) => QueuedRequest(
        method: method,
        path: path,
        body: body,
        timestamp: timestamp,
        retryCount: retryCount ?? this.retryCount,
      );
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Hive-backed FIFO queue for failed write operations (POST / PUT / DELETE).
///
/// Queued items are replayed in insertion order when connectivity is restored.
/// Auth tokens are never persisted — [TokenManager] provides a fresh token on
/// every replay attempt.
///
/// Limits:
/// - Max [_maxQueueSize] items (oldest discarded on overflow).
/// - Max [_maxRetries] attempts per item; failures beyond that are discarded.
/// - Entries older than [_maxAgeHours] hours are pruned automatically.
@LazySingleton()
class OfflineQueueService {
  OfflineQueueService(this._tokenManager, this._connectivityCubit);

  final TokenManager _tokenManager;
  final ConnectivityCubit _connectivityCubit;

  Box<String>? _box;
  StreamSubscription<ConnectivityState>? _connectivitySub;
  final StreamController<int> _countController =
      StreamController<int>.broadcast();

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  /// Opens the Hive box and subscribes to connectivity changes.
  ///
  /// Must be called once during app startup before using other methods.
  Future<void> initialize() async {
    _box = await Hive.openBox<String>(_boxName);
    await _pruneStaleEntries();
    _startConnectivityListener();
    _emitCount();
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Reactive count of pending queue entries.
  Stream<int> get queueCount => _countController.stream;

  /// Synchronous snapshot of pending queue length.
  int get pendingCount => _box?.length ?? 0;

  /// Adds [request] to the end of the queue.
  ///
  /// - Auth headers/tokens must be stripped by the caller before enqueuing.
  /// - Oldest item is discarded when the queue exceeds [_maxQueueSize].
  Future<void> enqueue(QueuedRequest request) async {
    final box = _requireBox();
    if (box.length >= _maxQueueSize) {
      // Discard oldest entry to stay within limit.
      final oldestKey = box.keys.first;
      await box.delete(oldestKey);
      debugPrint('[OfflineQueue] Max size reached — discarded oldest entry.');
    }

    final key = '${request.timestamp.millisecondsSinceEpoch}_${request.path}';
    await box.put(key, jsonEncode(request.toMap()));
    _emitCount();
    debugPrint('[OfflineQueue] Enqueued ${request.method} ${request.path}');
  }

  /// Convenience wrapper for calling [processQueue] on connectivity restore.
  ///
  /// Call this from an app-level [ConnectivityCubit] listener that already
  /// holds a [Dio] reference. Example integration in app.dart:
  ///
  /// ```dart
  /// connectivityCubit.stream.listen((state) {
  ///   if (state is ConnectivityOnline) {
  ///     offlineQueueService.processQueueOnReconnect(dio);
  ///   }
  /// });
  /// ```
  ///
  /// TODO: Wire this call in [app.dart] or the root [ConnectivityCubit] BLoC
  /// listener once a top-level [Dio] instance is accessible there.
  Future<void> processQueueOnReconnect(Dio dio) => processQueue(dio);

  /// Replays all queued requests in FIFO order using [dio].
  ///
  /// A fresh access token is fetched from [TokenManager] for each request.
  /// Items that fail are re-enqueued with an incremented retry count; items
  /// that have exceeded [_maxRetries] are discarded with a log entry.
  Future<void> processQueue(Dio dio) async {
    final box = _requireBox();
    if (box.isEmpty) return;

    await _pruneStaleEntries();

    final keys = List<dynamic>.from(box.keys);
    debugPrint('[OfflineQueue] Processing ${keys.length} queued request(s).');

    for (final key in keys) {
      final raw = box.get(key as String);
      if (raw == null) continue;

      final QueuedRequest request;
      try {
        request = QueuedRequest.fromMap(
          jsonDecode(raw) as Map<dynamic, dynamic>,
        );
      } on Exception catch (e) {
        debugPrint('[OfflineQueue] Failed to parse entry $key: $e — discarding');
        await box.delete(key);
        continue;
      }

      try {
        final token = await _tokenManager.accessToken;
        final headers = token != null ? {'Authorization': 'Bearer $token'} : <String, String>{};

        await dio.request<dynamic>(
          request.path,
          data: request.body,
          options: Options(method: request.method, headers: headers),
        );

        // Success — remove from queue.
        await box.delete(key);
        debugPrint('[OfflineQueue] Replayed ${request.method} ${request.path}');
      } on DioException catch (e) {
        debugPrint('[OfflineQueue] Replay failed for ${request.path}: $e');
        await box.delete(key);

        final updated = request.copyWith(retryCount: request.retryCount + 1);
        if (updated.retryCount >= _maxRetries) {
          debugPrint(
            '[OfflineQueue] Max retries reached for ${request.path} — discarding.',
          );
        } else {
          // Re-enqueue at end of queue with fresh timestamp preserved.
          final newKey =
              '${DateTime.now().millisecondsSinceEpoch}_${updated.path}';
          await box.put(newKey, jsonEncode(updated.toMap()));
        }
      }
    }

    _emitCount();
  }

  /// Removes all entries from the queue.
  Future<void> clearQueue() async {
    await _requireBox().clear();
    _emitCount();
    debugPrint('[OfflineQueue] Queue cleared.');
  }

  /// Cancels connectivity subscription and closes the Hive box.
  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    await _box?.close();
    await _countController.close();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _startConnectivityListener() {
    _connectivitySub = _connectivityCubit.stream.listen((state) {
      if (state is ConnectivityOnline) {
        debugPrint('[OfflineQueue] Connectivity restored — skip auto-process '
            '(caller must provide Dio instance).');
        // Auto-processing requires Dio; callers should call processQueueOnReconnect(dio)
        // from an app-level listener that has access to the Dio instance.
        //
        // Integration pattern (in app.dart or ConnectivityCubit listener):
        //
        //   context.read<ConnectivityCubit>().stream.listen((state) {
        //     if (state is ConnectivityOnline) {
        //       offlineQueueService.processQueueOnReconnect(dio);
        //     }
        //   });
      }
    });
  }

  void _emitCount() {
    if (!_countController.isClosed) {
      _countController.add(_box?.length ?? 0);
    }
  }

  Future<void> _pruneStaleEntries() async {
    final box = _requireBox();
    final cutoff = DateTime.now().subtract(
      const Duration(hours: _maxAgeHours),
    );
    final staleKeys = <dynamic>[];

    for (final key in box.keys) {
      final raw = box.get(key as String);
      if (raw == null) continue;
      try {
        final map = jsonDecode(raw) as Map<dynamic, dynamic>;
        final ts = DateTime.tryParse(map['timestamp'] as String? ?? '');
        if (ts != null && ts.isBefore(cutoff)) {
          staleKeys.add(key);
        }
      } on Exception {
        staleKeys.add(key); // malformed — discard
      }
    }

    if (staleKeys.isNotEmpty) {
      await box.deleteAll(staleKeys);
      debugPrint('[OfflineQueue] Pruned ${staleKeys.length} stale entries.');
      _emitCount();
    }
  }

  Box<String> _requireBox() {
    assert(_box != null, 'Call initialize() before using OfflineQueueService');
    return _box!;
  }
}
