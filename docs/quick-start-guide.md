# Quick start

## Run the app

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -t lib/main_development.dart
```

## Build a feature

Create the narrowest useful vertical slice:

1. Domain model
2. Repository contract
3. Use case
4. Data source and repository implementation
5. Injectable view model
6. Screen and route
7. View-model and widget tests

Minimal view-model shape:

```dart
@injectable
final class ProfileViewModel {
  ProfileViewModel(this._loadProfile);

  final LoadProfile _loadProfile;
  final _profile = signal<AsyncState<Profile>?>(null);

  ReadonlySignal<AsyncState<Profile>?> get profile => _profile;

  Future<void> load() async {
    _profile.value = AsyncState.loading();
    final result = await _loadProfile();
    result.fold(
      (error) => _profile.value = AsyncState.error(error),
      (profile) => _profile.value = AsyncState.data(profile),
    );
  }
}
```

Resolve it at the route boundary:

```dart
GoRoute(
  path: '/profile',
  builder: (_, _) => ProfileScreen(viewModel: getIt<ProfileViewModel>()),
)
```

Read the signal in `SignalWidget` or a focused `SignalBuilder`. Match
`AsyncData` and `AsyncError` before `AsyncLoading` so refreshing/reloading
states retain existing value/error semantics.

## Generate and verify

```sh
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

See the Home feature for a complete working example.
