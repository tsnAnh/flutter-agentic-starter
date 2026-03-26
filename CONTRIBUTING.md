# Contributing to flutter-agentic-starter

Thanks for your interest in contributing! This guide will help you get started.

## Getting Started

```sh
# Fork and clone
git clone https://github.com/YOUR_USERNAME/flutter-agentic-starter.git
cd flutter-agentic-starter

# Install dependencies
flutter pub get
dart run build_runner build

# Run (staging)
flutter run -t lib/main_staging.dart
```

## Development

### Prerequisites

- Flutter SDK 3.8+
- Dart SDK 3.8+
- Java 17+ (for Android builds)

### Code Generation

After modifying Freezed models or Injectable modules:

```sh
dart run build_runner build --delete-conflicting-outputs
```

### Running Tests

```sh
flutter test
```

## Code Style

- Follow existing patterns in the codebase
- Use [flutter_lints](https://pub.dev/packages/flutter_lints) rules (configured in `analysis_options.yaml`)
- BLoC pattern for state management
- Injectable for dependency injection
- Freezed for immutable data classes

## Pull Requests

### Branch Naming

- `feat/short-description` — new features
- `fix/short-description` — bug fixes
- `refactor/short-description` — refactoring
- `docs/short-description` — documentation

### Commit Messages

Use [conventional commits](https://www.conventionalcommits.org/):

```
feat: add user profile screen
fix: resolve login state persistence
refactor: extract network error handling
docs: update README quick start
```

### PR Checklist

- [ ] Code compiles without errors (`dart analyze`)
- [ ] Tests pass (`flutter test`)
- [ ] Follows existing architecture patterns
- [ ] Updated docs if needed

## Issues

- **Bug reports**: Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md)
- **Feature requests**: Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md)

## Code of Conduct

Be respectful, constructive, and inclusive. We're all here to build great software together.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](./LICENSE).
