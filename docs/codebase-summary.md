# Codebase summary

## Identity

- Product: Flutter Agentic Starter
- Dart package: `flutter_agentic_starter`
- App ID: `dev.example.flutteragenticstarter`
- Organization: `Example`

## Structure

```text
lib/
├── app.dart
├── main_development.dart
├── main_staging.dart
├── main_production.dart
├── core/
│   ├── analytics/
│   ├── auth/
│   ├── cache/
│   ├── connectivity/
│   ├── di/
│   ├── network/
│   ├── permissions/
│   └── router/
├── features/
│   └── home/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── shared/
    ├── i18n/
    └── widgets/
```

## Reactive owners

| Owner | Public signal | Lifetime |
| --- | --- | --- |
| `HomeViewModel` | `cities` | Route feature |
| `SessionManager` | `active` | App singleton |
| `ConnectivityService` | `online`, `offline` | App singleton |
| `OfflineQueueService` | `pendingCount` | App singleton |
| `PermissionViewModel` | `statuses` | Consumer-owned |

The Home feature demonstrates the complete flow from Dio data source through a
repository and use case to `ReadonlySignal<AsyncState<List<City>>?>`.

Generated registration lives in `lib/core/di/get_it.config.dart` and must only
be changed through source annotations plus build runner.
