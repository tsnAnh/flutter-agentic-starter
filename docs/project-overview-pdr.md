# Product development requirements

## Product

Flutter Agentic Starter is a production-ready Flutter template optimized for
human and AI-assisted feature delivery. It provides a small, explicit Signals
architecture without presentation event/state boilerplate.

## Goals

- Keep Clean Architecture boundaries testable.
- Make reactive state ownership obvious.
- Keep feature code small enough for surgical agent edits.
- Provide production integrations for navigation, networking, storage,
  analytics, crash reporting, localization, and offline writes.
- Preserve typed errors and avoid exposing implementation details to users.

## Functional requirements

1. Feature state is owned by injectable view models.
2. Mutable presentation state is private and exposed as `ReadonlySignal`.
3. Async work is represented by `AsyncState<T>`.
4. GoRouter passes view models into screens at route boundaries.
5. Session state starts signed out on every launch.
6. Connectivity and pending offline writes are signal-native.
7. Permission status rechecks on app resume.
8. The Home example demonstrates data/domain/presentation boundaries.
9. User-facing errors are localized and retryable.
10. Setup tooling can safely apply a new app identity and agent-skill name.

## Non-goals

- Compatibility adapters for the previous presentation architecture
- Migration of prior persisted authentication state
- A shared base view-model hierarchy
- Secure token persistence before a real authentication feature exists
- Speculative feature scaffolding

## Architecture decision

Signals 7 is the sole reactive presentation core. GetIt/Injectable remains the
composition mechanism; GoRouter, Dio, Hive, Freezed, and fpdart retain their
existing responsibilities.

## Acceptance

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build apk --release -t lib/main_staging.dart
```

Tracked source and guidance must contain no legacy state-management imports,
APIs, or old application identifiers.
