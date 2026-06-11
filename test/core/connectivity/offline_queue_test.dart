import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_bloc_base_source_code/core/auth/secure_storage_service.dart';
import 'package:flutter_bloc_base_source_code/core/auth/token_manager.dart';
import 'package:flutter_bloc_base_source_code/core/connectivity/offline_queue_replayer.dart';
import 'package:flutter_bloc_base_source_code/core/connectivity/queued_request.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('offline_queue_test_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('queued request serializes without auth headers', () {
    final request = QueuedRequest(
      method: 'POST',
      path: '/cities',
      body: {'name': 'Da Nang'},
      timestamp: DateTime.utc(2026, 6, 11),
    );

    final restored = QueuedRequest.fromJsonString(request.toJsonString());

    expect(restored.method, 'POST');
    expect(restored.path, '/cities');
    expect(restored.body, {'name': 'Da Nang'});
    expect(restored.timestamp, DateTime.utc(2026, 6, 11));
    expect(restored.toMap().containsKey('Authorization'), isFalse);
  });

  test('replayer prunes stale and malformed entries', () async {
    final box = await Hive.openBox<String>('offline_queue_prune_test');
    final replayer = OfflineQueueReplayer(
      tokenManager: TokenManager(SecureStorageService()),
      dio: Dio(),
    );

    await box.put(
      'fresh',
      QueuedRequest(
        method: 'POST',
        path: '/fresh',
        timestamp: DateTime.now(),
      ).toJsonString(),
    );
    await box.put(
      'stale',
      QueuedRequest(
        method: 'POST',
        path: '/stale',
        timestamp: DateTime.now().subtract(const Duration(hours: 25)),
      ).toJsonString(),
    );
    await box.put('malformed', '{');

    await replayer.pruneStaleEntries(box);

    expect(box.containsKey('fresh'), isTrue);
    expect(box.containsKey('stale'), isFalse);
    expect(box.containsKey('malformed'), isFalse);
  });
}
