[![CI](https://github.com/tsnAnh/flutter-agentic-starter/actions/workflows/dart.yml/badge.svg)](https://github.com/tsnAnh/flutter-agentic-starter/actions/workflows/dart.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.44+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10+-blue.svg)](https://dart.dev)

# Flutter Agentic Starter

Production-ready Flutter starter built for AI-assisted development with Signals
and Clean Architecture. Its predictable feature structure, project skills,
setup wizard, and generated catalog let coding agents start shipping without
repeated architecture prompts.

## Why this starter?

| Capability | Included |
| --- | :---: |
| AI instruction files and project skills | ✅ |
| Signals-based Clean Architecture | ✅ |
| Setup wizard and multi-flavor entry points | ✅ |
| Firebase, analytics, cache, and offline queue | ✅ |
| Generated Widgetbook catalog | ✅ |

## Stack

- Signals 7 for reactive presentation and service state
- GetIt + Injectable for composition
- GoRouter for navigation
- Dio + fpdart for typed network results
- Hive for local cache and offline writes
- Freezed + json_serializable for immutable wire/domain models
- Flutter localization, Material 3, Firebase, and PostHog integrations

## Architecture

Features use `data/domain/presentation` boundaries:

```text
Screen -> ViewModel -> Use case -> Repository -> Data source
   ^          |
   +-- ReadonlySignal<AsyncState<T>>
```

View models own private mutable signals and expose read-only signals. Screens
receive their view model at the route boundary and rebuild with `SignalWidget`
or a focused `SignalBuilder`. Services may expose signals for app-wide state,
such as `SessionManager.active`, `ConnectivityService.online`, and
`OfflineQueueService.pendingCount`.

See [System architecture](docs/system-architecture.md) and
[Code standards](docs/code-standards.md).

## Get started

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -t lib/main_development.dart
```

Available entry points:

- `lib/main_development.dart`
- `lib/main_staging.dart`
- `lib/main_production.dart`

## Widgetbook

Generate the catalog after adding or changing a use case:

```sh
dart run build_runner build --delete-conflicting-outputs
```

Run Widgetbook locally in Chrome:

```sh
flutter run -t lib/widgetbook/widgetbook.dart -d chrome
```

## Create a feature

1. Add the domain model, repository contract, and use case.
2. Implement the data source and repository.
3. Add an injectable `*ViewModel` with private `Signal` state.
4. Pass the view model from GoRouter into the screen.
5. Add focused view-model and widget tests.
6. Regenerate Injectable/Freezed/JSON code.

The Home feature is the reference implementation:
`lib/features/home/`.

## Customize the template

```sh
dart run project_setup \
  --app-name "Your App" \
  --dart-package-name your_app \
  --app-id com.example.yourapp \
  --organization Example \
  --yes
```

The checked-in template identity is:

- App name: `Flutter Agentic Starter`
- Dart package: `flutter_agentic_starter`
- Organization: `Example`
- Application ID: `dev.example.flutteragenticstarter`

## Verification

```sh
flutter analyze
flutter test
flutter build apk --release -t lib/main_staging.dart
```

## Agent guidance

Use `flutter-agentic-starter` only when implementing Flutter application code
under `lib/`, Flutter tests, or platform integration required by that code. It
does not apply to documentation, setup tooling, repository automation, or other
non-app maintenance.

Available skills:

- `flutter-agentic-starter` — Flutter/Signals/Clean Architecture rules
- `caveman` — concise technical communication
- `frontend-design` — polished user-facing Flutter UI

See [Documentation index](docs/README.md) and [Contributing](CONTRIBUTING.md).
