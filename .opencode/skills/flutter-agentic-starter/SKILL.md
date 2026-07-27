---
name: flutter-agentic-starter
description: >
  Project-specific Signals and Flutter implementation guidance for Flutter Agentic Starter.
  Use only when implementing Flutter application code, Flutter tests, or app-platform integration.
  Do not use for documentation,
  project setup tooling, repository automation, dependency-only maintenance, or agent configuration.
---

# Flutter Agentic Starter — Signals guide

## Scope and entry conditions

Use this skill for Flutter application implementation: screens, widgets, view
models, feature/domain/data code, app services, router changes, Flutter tests,
or platform integration required by those changes.

Do not use it for Markdown-only edits, project-setup code, CI/release work,
agent configuration, or a dependency-only change. Read `README.md`, the
relevant architecture guide, and nearby code before editing. Preserve unrelated
dirty-worktree changes.

## Architecture boundary

Use the existing feature shape:

```text
lib/features/<feature>/
├── data/           # API/local sources and repository implementations
├── domain/         # models, repository contracts, use cases
└── presentation/   # screens and injectable view models
```

- Presentation depends on domain, never Dio, Hive, or platform plugins.
- Data implements domain repository contracts and converts wire failures to
  typed domain errors.
- Use cases hold business operations; do not create an abstraction merely to
  forward a one-line call unless it is an actual domain boundary.
- Route constructors receive their view model at the GoRouter boundary through
  GetIt. Do not introduce inherited state providers for feature view models.

## State ownership

Choose the narrowest owner:

| State | Owner |
| --- | --- |
| Focus, controller text, expansion, one-screen animation | `StatefulWidget` + `setState` |
| Feature/shared async or business state | Injectable `*ViewModel` |
| App-lifetime cross-feature state | Focused lazy-singleton service |
| Derived state | `computed`, never duplicated mutable state |

Do not add a base view-model hierarchy. A concrete owner gets a `dispose` only
when it owns a resource that needs release.

## Signals API rules

Private mutable signals; public read-only signals:

```dart
@injectable
final class ProfileViewModel {
  ProfileViewModel(this._loadProfile);

  final LoadProfile _loadProfile;
  final _profile = signal<AsyncState<Profile>?>(null);

  ReadonlySignal<AsyncState<Profile>?> get profile => _profile;
}
```

- Never expose `Signal<T>` from a view model or service unless callers are the
  deliberate owner of writes.
- Use `computed` for a pure value derived from signals. Dispose it only when it
  has an independent finite lifetime.
- Use `batch` only when several writes are one observable transaction. Do not
  wrap ordinary single writes or async work in `batch`.
- Read `.value` only inside `SignalWidget`, `SignalBuilder`, `computed`, or a
  deliberate effect/subscription when reactive tracking is desired.
- Do not use `.watch(context)`, `.unwatch()`, or `SignalsMixin`.
- Do not create signals in a widget `build` method. `signals_lint` enforces
  these constraints during `flutter analyze`.

## Async state

Use `AsyncState<T>` for presentation-facing request lifecycle. Nullable
`AsyncState<T>` is valid when an intentional not-yet-requested state needs a
different UI from loading.

```dart
Future<void> load() async {
  if (_items.value is AsyncLoading<List<Item>>) return;

  _items.value = AsyncState.loading();
  final result = await _getItems();
  result.fold(
    (error) => _items.value = AsyncState.error(error),
    (items) => _items.value = AsyncState.data(items),
  );
}
```

- Guard duplicate loads unless concurrent requests are part of the requirement.
- Preserve a typed `NetworkError` in `AsyncState`; the UI shows a localized
  generic message, never `error.toString()`.
- When matching state, match `AsyncData` and `AsyncError` before `AsyncLoading`.
  Refreshing/reloading states also implement loading and can retain a value or
  error.
- A request that can be cancelled uses `RequestCancellationMixin` in the
  concrete view model and calls `cancelRequests()` from its own `dispose`.

## Widgets and rebuilds

Use `SignalWidget` when a small screen is signal-driven. Use `SignalBuilder`
around the smallest useful subtree when the shell is static:

```dart
SignalBuilder(
  builder: (context, _) {
    final state = viewModel.items.value;
    return switch (state) {
      AsyncData<List<Item>>(:final value) => ItemList(items: value),
      AsyncError<List<Item>>() => RetryPanel(onRetry: viewModel.load),
      AsyncLoading<List<Item>>() => const AppLoadingWidget(),
      null => LoadButton(onPressed: viewModel.load),
    };
  },
)
```

- Signal reads define rebuild dependencies. Keep them close to the leaf that
  needs them.
- Keep navigation, dialogs, snackbars, focus requests, and other one-shot UI
  effects at the widget boundary. View models expose state or an action result;
  they do not receive `BuildContext`.
- Prefer `const`, lazy `ListView.builder`/`GridView.builder`, `SafeArea`, ARB
  localization, semantic labels, and keyboard/focus support for custom controls.
- Build width-adaptive layouts from constraints; do not infer layout from device
  type or lock orientation.

## Effects, subscriptions, and lifecycle

Effects are exceptional. Prefer a direct action result or a computed value.
When an owner must subscribe, retain and release its cleanup:

```dart
EffectCleanup? _cleanup;

void start() {
  _cleanup = service.online.subscribe((online) {
    if (online) unawaited(replay());
  });
}

Future<void> dispose() async {
  _cleanup?.call();
  await _subscription?.cancel();
  _signal.dispose();
}
```

- The creator owns cleanup for effects, signal subscriptions, stream
  subscriptions, timers, computed values with a finite lifetime, Hive boxes,
  and `WidgetsBindingObserver` registrations.
- Make initialization idempotent where a service can be initialized more than
  once in tests or app startup paths.
- Do not retain a `BuildContext`, widget, or route in a service/view model.

## DI, routing, and app services

- Annotate view models, use cases, repositories, and data sources with
  Injectable according to their intended lifetime.
- Use lazy singletons for app-lifetime services; use factories for feature view
  models unless a scoped lifetime is explicitly required.
- Edit source annotations only, then run build runner; never edit
  `get_it.config.dart`, `*.g.dart`, or `*.freezed.dart` manually.
- Register a view model at the route boundary:

```dart
GoRoute(
  path: '/profile',
  builder: (_, _) => ProfileScreen(viewModel: getIt<ProfileViewModel>()),
)
```

- App services expose read-only signals just like view models. Their initial
  values must be safe before asynchronous initialization completes.

## Data, errors, and security

- Keep transport primitives at data boundaries. Map JSON and Dio failures to
  domain models and typed errors.
- Use repository results such as `Either<NetworkError, T>`; do not throw raw
  transport exceptions through presentation.
- Never log tokens, credentials, or full sensitive payloads. Do not put secrets
  in source, tests, generated files, or reports.
- Validate untrusted input at the boundary. Keep identifiers/value objects typed
  when they carry finite or high-risk domain meaning.

## Testing and verification

- Unit-test each non-trivial view-model transition: initial, loading, success,
  error, duplicate request behavior, and disposal when applicable.
- Use small fakes for repositories and platform services. Avoid broad mocks.
- Add widget tests for the visible user flow and localized error/retry behavior.
- Test lifecycle rechecks, reconnect replay, and cleanup for long-lived
  reactive services.
- Run the smallest relevant checks, then at minimum after Flutter code changes:

```sh
dart run build_runner build --delete-conflicting-outputs # DI/model source changed
flutter analyze
flutter test
```

## Review checklist

- Is state owned by the narrowest correct object?
- Are mutable signals private and public signals read-only?
- Is async work represented by `AsyncState` and errors localized?
- Are rebuilds limited to the signal-consuming subtree?
- Are one-shot effects outside the view model?
- Are every owned effect, subscription, connection, timer, and observer disposed?
- Are generated files untouched and required checks passing?
