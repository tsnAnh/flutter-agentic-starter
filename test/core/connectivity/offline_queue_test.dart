import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:dio/dio.dart';
import 'package:flutter_agentic_starter/core/auth/secure_storage_service.dart';
import 'package:flutter_agentic_starter/core/auth/token_manager.dart';
import 'package:flutter_agentic_starter/core/connectivity/connectivity_service.dart';
import 'package:flutter_agentic_starter/core/connectivity/offline_queue_service.dart';
import 'package:flutter_agentic_starter/core/connectivity/offline_queue_replayer.dart';
import 'package:flutter_agentic_starter/core/connectivity/queued_request.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late ConnectivityPlatform originalConnectivity;

  setUp(() async {
    originalConnectivity = ConnectivityPlatform.instance;
    tempDir = await Directory.systemTemp.createTemp('offline_queue_test_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    ConnectivityPlatform.instance = originalConnectivity;
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

  test('signals connectivity and replays queued work on reconnect', () async {
    final platform = _ConnectivityPlatform();
    ConnectivityPlatform.instance = platform;
    final connectivity = ConnectivityService();
    await connectivity.init();
    expect(connectivity.online.value, isFalse);

    var replayCount = 0;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            replayCount++;
            handler.resolve(Response(requestOptions: options, statusCode: 200));
          },
        ),
      );
    final queue = OfflineQueueService(
      TokenManager(SecureStorageService()),
      connectivity,
      dio,
    );
    await queue.initialize();
    await queue.enqueue(
      QueuedRequest(method: 'POST', path: '/cities', timestamp: DateTime.now()),
    );
    expect(queue.pendingCount.value, 1);

    platform.emit([ConnectivityResult.wifi]);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(connectivity.online.value, isTrue);
    expect(connectivity.offline.value, isFalse);
    expect(replayCount, 1);
    expect(queue.pendingCount.value, 0);

    await queue.dispose();
    await connectivity.dispose();
    await platform.close();
  });
}

final class _ConnectivityPlatform extends ConnectivityPlatform {
  final _changes = StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => [
    ConnectivityResult.none,
  ];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _changes.stream;

  void emit(List<ConnectivityResult> results) => _changes.add(results);

  Future<void> close() => _changes.close();
}
