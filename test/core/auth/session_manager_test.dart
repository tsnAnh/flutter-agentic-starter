import 'package:flutter_agentic_starter/core/auth/session_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('active signal follows start and explicit logout', () async {
    final manager = SessionManager(
      inactivityTimeout: const Duration(seconds: 1),
    );
    addTearDown(manager.dispose);

    expect(manager.active.value, isFalse);

    manager.startSession();
    expect(manager.active.value, isTrue);

    final event = manager.events.first;
    manager.endSession();

    expect(manager.active.value, isFalse);
    expect(await event, SessionEvent.sessionEnded);
  });

  test('inactivity expiry signs out and emits expiry', () async {
    final manager = SessionManager(
      inactivityTimeout: const Duration(milliseconds: 10),
    );
    addTearDown(manager.dispose);

    final event = manager.events.first;
    manager.startSession();

    expect(await event, SessionEvent.sessionExpired);
    expect(manager.active.value, isFalse);
  });
}
