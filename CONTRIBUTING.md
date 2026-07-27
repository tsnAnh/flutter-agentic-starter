# Contributing

## Before editing

Read `README.md`, the relevant file in `docs/`, and the repository agent
instructions. Preserve unrelated work in dirty worktrees.

## Architecture rules

- Keep feature code in `data/domain/presentation`.
- Put business rules in use cases and data access behind repositories.
- Use injectable `*ViewModel` classes for feature presentation state.
- Keep mutable `Signal` fields private; expose `ReadonlySignal`.
- Use `AsyncState<T>` for loading, data, and error.
- Keep ephemeral widget-only state in the widget.
- Pass view models at the route boundary.
- Localize every production user-facing string.
- Never show raw exceptions to users.
- Dispose owned effects, subscriptions, connections, timers, and lifecycle
  observers.

Do not use `.watch(context)` or `SignalsMixin`.

## Generated code

Never edit `*.g.dart`, `*.freezed.dart`, or `*.config.dart` manually. Edit the
source and run:

```sh
dart run build_runner build --delete-conflicting-outputs
```

## Checks

```sh
flutter analyze
flutter test
```

Run the relevant platform build for platform or release changes. Keep commits
focused and use conventional commit messages when a commit is requested.
