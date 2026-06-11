import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../auth/token_manager.dart';
import 'offline_queue_config.dart';
import 'queued_request.dart';

class OfflineQueueReplayer {
  const OfflineQueueReplayer({
    required TokenManager tokenManager,
    required Dio dio,
  }) : _tokenManager = tokenManager,
       _dio = dio;

  final TokenManager _tokenManager;
  final Dio _dio;

  Future<void> process(Box<String> box) async {
    if (box.isEmpty) return;

    await pruneStaleEntries(box);

    final keys = List<dynamic>.from(box.keys);
    debugPrint('[OfflineQueue] Processing ${keys.length} queued request(s).');

    for (final key in keys) {
      final raw = box.get(key as String);
      if (raw == null) continue;

      final QueuedRequest request;
      try {
        request = QueuedRequest.fromJsonString(raw);
      } on Exception catch (e) {
        debugPrint(
          '[OfflineQueue] Failed to parse entry $key: $e - discarding',
        );
        await box.delete(key);
        continue;
      }

      await _replayRequest(box, key, request);
    }
  }

  Future<void> pruneStaleEntries(Box<String> box) async {
    final cutoff = DateTime.now().subtract(
      const Duration(hours: offlineQueueMaxAgeHours),
    );
    final staleKeys = <dynamic>[];

    for (final key in box.keys) {
      final raw = box.get(key as String);
      if (raw == null) continue;
      try {
        final request = QueuedRequest.fromJsonString(raw);
        if (request.timestamp.isBefore(cutoff)) staleKeys.add(key);
      } on Exception {
        staleKeys.add(key);
      }
    }

    if (staleKeys.isNotEmpty) {
      await box.deleteAll(staleKeys);
      debugPrint('[OfflineQueue] Pruned ${staleKeys.length} stale entries.');
    }
  }

  Future<void> _replayRequest(
    Box<String> box,
    String key,
    QueuedRequest request,
  ) async {
    try {
      final token = await _tokenManager.accessToken;
      final headers = token != null
          ? {'Authorization': 'Bearer $token'}
          : <String, String>{};

      await _dio.request<dynamic>(
        request.path,
        data: request.body,
        options: Options(method: request.method, headers: headers),
      );

      await box.delete(key);
      debugPrint('[OfflineQueue] Replayed ${request.method} ${request.path}');
    } on DioException catch (e) {
      debugPrint('[OfflineQueue] Replay failed for ${request.path}: $e');
      await box.delete(key);

      final updated = request.copyWith(retryCount: request.retryCount + 1);
      if (updated.retryCount >= offlineQueueMaxRetries) {
        debugPrint(
          '[OfflineQueue] Max retries reached for ${request.path} - discarding.',
        );
        return;
      }

      final newKey = '${DateTime.now().millisecondsSinceEpoch}_${updated.path}';
      await box.put(newKey, updated.toJsonString());
    }
  }
}
