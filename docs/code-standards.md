# Code standards

## Feature layout

```text
lib/features/<feature>/
├── data/
│   ├── repositories/
│   └── sources/
├── domain/
│   ├── models/
│   ├── repositories/
│   └── use_cases/
└── presentation/
    ├── <feature>_screen.dart
    └── <feature>_view_model.dart
```

Dependencies point inward: presentation uses domain; data implements domain.
Infrastructure shared by features belongs in `lib/core/`.

## Signals

View models are small injectable classes, not a shared base hierarchy:

```dart
@injectable
final class ItemsViewModel {
  ItemsViewModel(this._getItems);

  final GetItems _getItems;
  final _items = signal<AsyncState<List<Item>>?>(null);

  ReadonlySignal<AsyncState<List<Item>>?> get items => _items;

  Future<void> load() async {
    if (_items.value is AsyncLoading<List<Item>>) return;
    _items.value = AsyncState.loading();
    final result = await _getItems();
    result.fold(
      (error) => _items.value = AsyncState.error(error),
      (items) => _items.value = AsyncState.data(items),
    );
  }
}
```

Rules:

- Keep `Signal` mutable state private.
- Expose `ReadonlySignal` rather than the mutable signal.
- Prefer `computed` to duplicated derived state.
- Use `batch` when two or more signal writes form one observable transaction.
- Use `AsyncState<T>` for async loading/data/error.
- Preserve an intentional initial state with nullable `AsyncState` when needed.
- Ignore duplicate load actions while loading unless concurrency is intentional.
- Do not put Flutter navigation or dialogs in view models.
- Do not use `.watch(context)` or `SignalsMixin`.

## Widgets and rebuilds

Use `SignalWidget` when most of a small screen depends on signals. Use
`SignalBuilder` around the smallest useful subtree when the surrounding widget
is static. Reading a signal's `.value` inside either establishes the reactive
dependency.

One-shot actions such as navigation, dialogs, and snackbars remain widget
responsibilities. Prefer handling the result of a user action. If an `effect`
or `subscribe` connection is required, store its cleanup callback and invoke it
from `dispose`.

## Disposal

Every object that creates a timer, stream subscription, signal subscription,
effect, computed value with independent lifetime, or `WidgetsBindingObserver`
must release it. The object that creates the resource owns cleanup.

Do not introduce a base view-model class solely for disposal. Add `dispose`
only to the concrete owner that needs it.

## Data and errors

- Data sources translate transport failures into `NetworkError`.
- Repositories return `Either<NetworkError, T>`.
- Use cases express domain operations.
- View models may keep the typed error in `AsyncState`.
- UI renders a localized generic message and never raw exceptions.
- Parse raw JSON only at data boundaries.

## Dependency injection

Annotate feature classes and regenerate with build runner. Route factories
resolve a feature view model and pass it to the screen. Long-lived services use
lazy singletons; feature view models use factories.

## UI and localization

Use Material 3, `SafeArea`, lazy list/grid builders, accessible semantics, and
width-adaptive layouts. Route production text through ARB resources for every
supported locale.

## Testing

Use small fakes. Test view-model state transitions directly, then one widget
test for the user-visible flow. Test cleanup and reconnection behavior for
long-lived services.

Required baseline:

```sh
flutter analyze
flutter test
```

`flutter analyze` also runs the `signals_lint` analyzer plugin.
