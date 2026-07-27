import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:signals/signals.dart';

import '../auth/token_manager.dart';
import '../network/dio.dart';
import 'connectivity_service.dart';
import 'offline_queue_config.dart';
import 'offline_queue_replayer.dart';
import 'queued_request.dart';

/// Hive-backed FIFO queue for failed write operations (POST / PUT / DELETE).
///
/// Queued items are replayed in insertion order when connectivity is restored.
/// Auth tokens are never persisted — [TokenManager] provides a fresh token on
/// every replay attempt.
///
/// Limits:
/// - Max [offlineQueueMaxSize] items (oldest discarded on overflow).
/// - Max replay attempts are controlled by [OfflineQueueReplayer].
/// - Stale entries are pruned automatically.
@LazySingleton()
class OfflineQueueService {
  OfflineQueueService(
    TokenManager tokenManager,
    this._connectivityService,
    @nonAuthDio Dio replayDio,
  ) : _replayer = OfflineQueueReplayer(
        tokenManager: tokenManager,
        dio: replayDio,
      );

  final ConnectivityService _connectivityService;
  final OfflineQueueReplayer _replayer;

  Box<String>? _box;
  EffectCleanup? _connectivityCleanup;
  final _pendingCount = signal(0);

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  /// Opens the Hive box and subscribes to connectivity changes.
  ///
  /// Must be called once during app startup before using other methods.
  Future<void> initialize() async {
    _box = await Hive.openBox<String>(offlineQueueBoxName);
    await _replayer.pruneStaleEntries(_requireBox());
    _startConnectivityListener();
    _emitCount();
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Reactive count of pending queue entries.
  ReadonlySignal<int> get pendingCount => _pendingCount;

  /// Adds [request] to the end of the queue.
  ///
  /// - Auth headers/tokens must be stripped by the caller before enqueuing.
  /// - Oldest item is discarded when the queue exceeds [offlineQueueMaxSize].
  Future<void> enqueue(QueuedRequest request) async {
    final box = _requireBox();
    if (box.length >= offlineQueueMaxSize) {
      // Discard oldest entry to stay within limit.
      final oldestKey = box.keys.first;
      await box.delete(oldestKey);
      debugPrint('[OfflineQueue] Max size reached - discarded oldest entry.');
    }

    final key = '${request.timestamp.millisecondsSinceEpoch}_${request.path}';
    await box.put(key, request.toJsonString());
    _emitCount();
    debugPrint('[OfflineQueue] Enqueued ${request.method} ${request.path}');
  }

  /// Convenience wrapper for replaying queued writes on connectivity restore.
  Future<void> processQueueOnReconnect() => processQueue();

  /// Replays all queued requests in FIFO order.
  Future<void> processQueue() async {
    final box = _requireBox();
    await _replayer.process(box);
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
    _connectivityCleanup?.call();
    await _box?.close();
    _pendingCount.dispose();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _startConnectivityListener() {
    _connectivityCleanup?.call();
    _connectivityCleanup = _connectivityService.online.subscribe((online) {
      if (online) {
        processQueueOnReconnect().ignore();
      }
    });
  }

  void _emitCount() {
    _pendingCount.value = _box?.length ?? 0;
  }

  Box<String> _requireBox() {
    assert(_box != null, 'Call initialize() before using OfflineQueueService');
    return _box!;
  }
}
