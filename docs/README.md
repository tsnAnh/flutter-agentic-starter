# Flutter BLoC Base Documentation

Welcome to the Flutter BLoC Base project documentation. This is a comprehensive, production-ready template for building scalable Flutter applications using Clean Architecture and the BLoC pattern.

## Quick Links

### For New Developers
Start here if you're new to the project:

1. **[Quick Start Guide](./quick-start-guide.md)** (30 min)
   - 5-minute setup
   - First feature walkthrough
   - Common patterns
   - Debugging tips

2. **[Codebase Summary](./codebase-summary.md)** (15 min)
   - Project overview
   - Module descriptions
   - Architecture overview
   - Key features

### For Understanding Architecture
Deep dives into how the system works:

1. **[System Architecture](./system-architecture.md)** (45 min)
   - Clean Architecture explanation
   - Component architecture
   - Data flow examples
   - Dependency graphs

2. **[Code Standards](./code-standards.md)** (30 min)
   - Naming conventions
   - Code patterns (Repository, UseCase, Cubit, BLoC)
   - Quality standards
   - Best practices

### For Implementation Details
Module-specific implementation guides:

1. **[Module Implementation Guides](./module-guides.md)** (60 min)
   - 8 detailed module guides
   - Setup instructions
   - Usage examples
   - Customization options

### For Project Management
Strategic and planning documents:

1. **[Project Overview & PDR](./project-overview-pdr.md)** (20 min)
   - Project vision
   - Functional requirements
   - Architecture decisions
   - Success metrics

2. **[Development Roadmap](./development-roadmap.md)** (15 min)
   - Current status (v1.0.0)
   - Q2 2026 roadmap
   - Q3 2026 roadmap
   - Q4 2026 roadmap

## Documentation Structure

```
docs/
├── README.md (this file)
├── quick-start-guide.md          ← START HERE for 30-min onboarding
├── codebase-summary.md           ← Overview of all 18 modules
├── system-architecture.md        ← Deep dive into architecture
├── code-standards.md             ← Coding patterns & guidelines
├── module-guides.md              ← Implementation guides (8 modules)
├── project-overview-pdr.md       ← Vision, requirements, decisions
└── development-roadmap.md        ← Future plans & timeline
```

## Key Statistics

| Metric | Value |
|--------|-------|
| **Total Dart Files** | 143 |
| **Core Modules** | 18 |
| **Infrastructure Coverage** | 100% |
| **Lines of Documentation** | 1500+ |
| **Example Features** | 2 (Login, Home) |
| **API Endpoints Supported** | Unlimited |
| **Team Size Support** | 5-50 developers |

## Core Modules Overview

The project provides 18 pre-built infrastructure modules:

| # | Module | Purpose | Status |
|---|--------|---------|--------|
| 1 | **DataState** | Type-safe async state | ✅ Complete |
| 2 | **BaseCubit/Repository** | Base classes | ✅ Complete |
| 3 | **Networking** | HTTP client + 5 interceptors | ✅ Complete |
| 4 | **Caching** | Multi-layer cache (memory + disk) | ✅ Complete |
| 5 | **Connectivity** | Offline-first support | ✅ Complete |
| 6 | **Authentication** | Token & session management | ✅ Complete |
| 7 | **Firebase** | Crashlytics, FCM, RemoteConfig | ✅ Complete |
| 8 | **Analytics** | Firebase + PostHog abstraction | ✅ Complete |
| 9 | **Permissions** | Unified permission handling | ✅ Complete |
| 10 | **Design System** | Centralized design tokens | ✅ Complete |
| 11 | **Extensions** | 8 utility extension types | ✅ Complete |
| 12 | **Utils** | 10+ utility modules | ✅ Complete |
| 13 | **Router** | Deep linking & routing | ✅ Complete |
| 14 | **Lifecycle** | App lifecycle management | ✅ Complete |
| 15 | **Logger** | Structured logging | ✅ Complete |
| 16 | **DI** | GetIt-based injection | ✅ Complete |
| 17 | **Theme** | Material 3 theming | ✅ Complete |
| 18 | **Forms** | FormZ-based validation | ✅ Complete |

## Recommended Reading Order

### Day 1: Foundation (4 hours)
1. Quick Start Guide (30 min)
2. Codebase Summary (15 min)
3. Set up development environment (30 min)
4. Create first test feature (2 hours)
5. Review code standards (45 min)

### Day 2-3: Architecture Deep Dive (6 hours)
1. System Architecture (45 min)
2. Module Implementation Guides (3 hours)
3. Networking & Caching deep dive (1.5 hours)
4. Code patterns & best practices (45 min)

### Day 4+: Project-Specific Implementation
1. Review Project Overview & PDR (20 min)
2. Implement your features following patterns (varies)
3. Review Development Roadmap (15 min)
4. Plan team workflow and code review process

## Getting Started in 5 Minutes

```bash
# 1. Clone repository
git clone https://github.com/tsnAnh/flutter-bloc-base-source-code.git
cd flutter-bloc-base-source-code

# 2. Install dependencies
flutter pub get
dart run build_runner build

# 3. Run the app
flutter run -t lib/main_staging.dart

# 4. Explore the code
# - Login feature: lib/features/login/
# - Home feature: lib/features/home/
# - Infrastructure: lib/core/
```

## Architecture at a Glance

```
Presentation Layer (UI)
    ↓ depends on ↓
Domain Layer (Business Logic)
    ↓ implements ↓
Data Layer (Repositories)
    ↓ uses ↓
Infrastructure Layer (Services)
```

**Key Patterns**:
- **State Management**: BLoC + Cubit with DataState
- **Data Access**: Repository pattern with caching
- **Dependency Injection**: GetIt service locator
- **Error Handling**: Sealed classes + pattern matching
- **Network**: Dio with 5 specialized interceptors

## Common Tasks

### Create a New Feature

See [Quick Start Guide → Your First Feature](./quick-start-guide.md#your-first-feature-1-2-hours)

### Add Caching to a Repository

See [Module Guides → Caching Module](./module-guides.md#caching-module)

### Integrate Firebase

See [Module Guides → Firebase Module](./module-guides.md#firebase-module)

### Set Up Analytics

See [Module Guides → Analytics Module](./module-guides.md#analytics-module)

### Handle Offline Requests

See [Module Guides → Connectivity Module](./module-guides.md#connectivity-module)

### Style Your App

See [Module Guides → Design System Module](./module-guides.md#design-system-module)

### Debug Network Issues

See [Quick Start Guide → Debugging Tips](./quick-start-guide.md#debugging-tips)

## Code Quality Standards

- **Naming**: `snake_case` files, `PascalCase` classes, `camelCase` variables
- **Structure**: Clean Architecture with clear layer separation
- **Testing**: Unit tests for core modules, widget tests for UI
- **Documentation**: Doc comments for public APIs
- **Linting**: Zero warnings, consistent formatting

See [Code Standards](./code-standards.md) for detailed guidelines.

## API Reference

Quick reference for common APIs:

### DataState Pattern
```dart
sealed class DataState<T> {
  DataStateInitial<T>()         // Initial state
  DataStateLoading<T>()         // Loading
  DataStateLoaded<T>(data)      // Success
  DataStateError<T>(message)    // Error
}
```

### Cubit Usage
```dart
class MyCubit extends BaseCubit<Data> {
  @override
  Future<Data> fetch() => repository.getData();
}
```

### Repository Pattern
```dart
abstract class MyRepository extends BaseRepository
    with CachedRepositoryMixin {
  Future<Data> getData();
}
```

### Dependency Injection
```dart
getIt.registerSingleton<Service>(Service());
final service = getIt<Service>();
```

For more, see [Module Guides](./module-guides.md).

## Performance Tips

1. **Caching**: Use `CachedRepositoryMixin` for automatic caching
2. **Pagination**: Use `BasePaginatedCubit` for list pagination
3. **Lazy Loading**: Register services as lazy singletons
4. **Offline**: Use `OfflineQueueService` for offline-first
5. **Memory**: Dispose streams/controllers in Cubit.close()

## Security Best Practices

1. **Secrets**: Never commit `.env` files
2. **Tokens**: Use `SecureStorageService` for sensitive data
3. **Validation**: Validate all API responses
4. **HTTPS**: All API calls use HTTPS
5. **Authentication**: Automatic token refresh via interceptor

## FAQs

### Q: Where should I put my code?
A: Follow the feature structure in [Quick Start Guide](./quick-start-guide.md).

### Q: How do I add a new module?
A: Create `lib/core/[module]/` and follow patterns in [Code Standards](./code-standards.md).

### Q: How do I test my code?
A: See testing patterns in [Code Standards → Testing](./code-standards.md#testing).

### Q: How do I handle errors?
A: Use custom exceptions and `DataStateError`. See [Code Standards](./code-standards.md#error-handling).

### Q: How do I cache data?
A: Use `CachedRepositoryMixin`. See [Module Guides → Caching](./module-guides.md#caching-module).

### Q: How do I support offline?
A: Use `OfflineQueueService`. See [Module Guides → Connectivity](./module-guides.md#connectivity-module).

## Troubleshooting

### App won't start
- [ ] Run `flutter clean && flutter pub get`
- [ ] Run `dart run build_runner build`
- [ ] Check Flutter version (3.13+)

### Service not found in GetIt
- [ ] Add registration in `lib/core/di/get_it.dart`
- [ ] Ensure registration is called before usage

### Network requests failing
- [ ] Check API base URL in `DioClient`
- [ ] Verify token in secure storage
- [ ] Check Dio timeout settings

### State not updating
- [ ] Ensure new state is emitted (not assigned)
- [ ] Check BlocBuilder/BlocListener context
- [ ] Verify Cubit is provided to widget

## Contributing

Want to improve documentation?
1. Fork the repository
2. Make changes
3. Submit pull request
4. Follow [Code Standards](./code-standards.md)

## Support & Resources

| Resource | Link |
|----------|------|
| **GitHub Repository** | [tsnAnh/flutter-bloc-base-source-code](https://github.com/tsnAnh/flutter-bloc-base-source-code) |
| **Example Project** | [bit](https://github.com/tsnAnh/bit) |
| **Flutter Docs** | [flutter.dev](https://flutter.dev) |
| **BLoC Library** | [bloclibrary.dev](https://bloclibrary.dev) |
| **Dart Language** | [dart.dev](https://dart.dev) |

## Version Info

- **Project Version**: 1.0.0
- **Flutter Target**: 3.13+
- **Dart Target**: 3.1+
- **Last Updated**: March 2026

## License

See LICENSE file in repository.

---

**Happy coding!** 🚀

Start with the [Quick Start Guide](./quick-start-guide.md) to begin building your feature.

