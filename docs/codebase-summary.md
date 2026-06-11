# Flutter BLoC Base Codebase Summary

## Overview

Flutter BLoC Base is a production-ready, modular Flutter template implementing clean architecture with the BLoC pattern. The codebase provides reusable infrastructure for rapid feature development.

**Repository**: [flutter-agentic-starter](https://github.com/tsnAnh/flutter-agentic-starter)

## Statistics

- **Total Files**: 153 Dart files
- **Total Modules**: 17 core module groups
- **Architecture**: Clean Architecture + BLoC Pattern
- **Dependency Injection**: GetIt with automatic configuration

## Project Structure

```
lib/
├── core/                          # Infrastructure & utilities
│   ├── analytics/                 # Analytics abstraction (Firebase, PostHog)
│   ├── auth/                      # Authentication & token management
│   ├── base/                      # Base classes (DataState, Cubits, UseCase)
│   ├── cache/                     # Caching layer (memory, disk)
│   ├── connectivity/              # Offline support & connectivity detection
│   ├── design_system/             # Design tokens (colors, spacing, typography)
│   ├── di/                        # Dependency injection configuration
│   ├── extensions/                # Utility extensions (string, datetime, etc.)
│   ├── firebase/                  # Firebase services (Crashlytics, FCM, etc.)
│   ├── lifecycle/                 # App lifecycle management
│   ├── logger/                    # Structured logging
│   ├── network/                   # HTTP client & interceptors
│   ├── permissions/               # Permission handling
│   ├── router/                    # Deep linking & routing
│   ├── theme/                     # Material theme configuration
│   ├── utils/                     # Utility functions
│   ├── app_bloc_observer.dart     # BLoC event/state observer
│   └── error.dart                 # Global error handling
│
├── shared/                        # Feature-agnostic shared code
│   ├── blocs/                     # Global BLoCs/Cubits
│   ├── data/                      # Repositories & models
│   ├── forms/                     # Form input validation
│   ├── i18n/                      # Localization
│   ├── services/                  # Shared services
│   └── widgets/                   # Reusable UI components
│
└── features/                      # Feature modules
    └── home/                      # Home feature
        ├── bloc/                  # BLoC layer
        ├── cubit/                 # Cubit layer (alternative)
        └── home_screen.dart       # UI layer

```

## Core Modules

### 1. Base Architecture (`core/base/`)
- **DataState**: Sealed class representing async data lifecycle (Initial, Loading, Loaded, Error)
- **BaseCubit**: Abstract cubit managing DataState with load/refresh methods
- **BasePaginatedCubit**: Extended cubit for pagination support
- **UseCase**: Abstract use case for business logic
- **BaseRepository**: Abstract repository for data access

### 2. Design System (`core/design_system/`)
Centralized design tokens accessible via ThemeExtension:
- **Colors**: Semantic color tokens
- **Spacing**: Margin/padding values
- **Radius**: Border radius constants
- **Shadows**: Elevation and shadow definitions
- **Typography**: Text style tokens
- **Durations**: Animation timing constants

### 3. Networking (`core/network/`)
Dio-based HTTP client with interceptors:
- **RetryInterceptor**: Automatic retry logic with exponential backoff
- **CacheInterceptor**: HTTP response caching
- **ConnectivityInterceptor**: Offline-aware request queueing
- **LoggingInterceptor**: Request/response logging
- **AuthenticationInterceptor**: Token attachment and refresh

### 4. Caching (`core/cache/`)
Multi-layer caching strategy:
- **MemoryCache**: In-memory cache with TTL
- **DiskCache**: Persistent file-based cache
- **CacheManager**: High-level cache coordination
- **CachedRepositoryMixin**: Easy cache integration for repositories

### 5. Connectivity (`core/connectivity/`)
Offline-first support:
- **ConnectivityService**: Real-time connectivity status
- **ConnectivityCubit**: Reactive connectivity state
- **OfflineQueueService**: Queue requests when offline
- **OfflineAwareMixin**: Mixin for offline-aware data operations

### 6. Authentication (`core/auth/`)
Token & session management:
- **SecureStorageService**: Encrypted credential storage
- **TokenManager**: Token lifecycle management
- **SessionManager**: User session handling
- **AuthenticationInterceptor**: Token injection into requests

### 7. Firebase Services (`core/firebase/`)
Firebase ecosystem integration:
- **FirebaseInitializer**: Setup & configuration
- **CrashlyticsService**: Error reporting
- **PushNotificationService**: FCM integration
- **RemoteConfigService**: Dynamic configuration
- **AppCheckService**: Abuse protection

### 8. Analytics (`core/analytics/`)
Multi-provider analytics abstraction:
- **FirebaseAnalyticsProvider**: Firebase Analytics
- **PostHogAnalyticsProvider**: PostHog integration
- **CompositeAnalyticsProvider**: Route to multiple providers
- **AnalyticsMixin**: Widget-level analytics tracking

### 9. Permissions (`core/permissions/`)
Unified permission handling:
- **PermissionService**: Abstraction layer
- **PermissionCubit**: Reactive permission state
- **PermissionHandlerImpl**: Platform implementation

### 10. Extensions (`core/extensions/`)
Utility extension methods:
- **StringExtensions**: Text manipulation (camelCase, snake_case, etc.)
- **DateTimeExtensions**: Date formatting and calculations
- **IterableExtensions**: Collection utilities
- **NumExtensions**: Number formatting
- **WidgetExtensions**: Widget builders
- **FutureExtensions**: Async helpers
- **ContextExtensions**: BuildContext utilities

### 11. Router (`core/router/`)
Deep linking and navigation:
- **DeepLinkHandler**: Parse and route deep links
- **RouteParams**: Type-safe route parameter handling

### 12. Lifecycle Management (`core/lifecycle/`)
App state management:
- **AppLifecycleObserver**: Foreground/background transitions
- **AppUpdateChecker**: Version update detection

### 13. Utils (`core/utils/`)
Utility functions:
- **ColorUtils**: Color manipulation
- **DateUtils**: Date formatting and parsing
- **StringUtils**: String manipulation
- **NumberUtils**: Number formatting
- **ResponseUtils**: Responsive layout helpers
- **SnackbarUtils**: Toast notifications
- **UrlUtils**: URL validation and parsing
- **Debouncer/Throttler**: Event rate limiting

### 14. Logging (`core/logger/`)
Structured logging:
- **DebugLogger**: Development logging with full details
- **ProductionLogger**: Production logging with filtering
- **ConsoleOutput**: Console output formatting

### 15. Dependency Injection (`core/di/`)
GetIt-based service locator:
- **get_it.dart**: Service registration
- **get_it.config.dart**: Auto-generated configuration

### 16. Theme (`core/theme/`)
Material Design theming:
- **ColorSchemes**: Light and dark color definitions
- **ThemeData**: Complete theme configuration

### 17. Shared Forms (`shared/forms/`)
Formz-based input validation:
- **EmailInput**: Email validation
- **PasswordInput**: Password strength rules
- **PhoneInput**: Phone number validation
- **NumericInput**: Number input validation

### 18. Feature Layer
The Home example feature demonstrates:
- BLoC/Cubit usage patterns
- Data repository pattern
- Model definition (DTO and domain models)
- UI implementation with state management

## Key Architectural Patterns

### BLoC Pattern
- Events drive state transitions
- Separates business logic from UI
- Reactive state management

### Clean Architecture Layers
1. **Presentation**: UI components and state management
2. **Domain**: Business logic and entities
3. **Data**: Repositories and data sources

### Sealed Classes for Type Safety
- `DataState<T>` for state lifecycle
- Pattern matching for exhaustive handling

### Repository Pattern
- `BaseRepository` provides data abstraction
- `CachedRepositoryMixin` adds caching capability
- Supports multiple data sources

### Dependency Injection
- GetIt service locator
- Lazy singleton registration
- Module-based configuration

## Dependencies

### Core
- **flutter_bloc**: State management
- **dio**: HTTP client
- **get_it**: Service locator
- **formz**: Form validation

### Firebase
- **firebase_core**
- **firebase_analytics**
- **firebase_crashlytics**
- **firebase_messaging**
- **firebase_remote_config**
- **app_check**

### Utilities
- **flutter_secure_storage**: Encrypted storage
- **connectivity_plus**: Network detection
- **device_info_plus**: Device information
- **permission_handler**: Permission management
- **url_launcher**: URL handling

## Development Workflow

### Setup
```bash
flutter pub get
dart run build_runner build
```

### Running
```bash
flutter run -t lib/main_staging.dart       # Staging
flutter run -t lib/main_production.dart    # Production
```

### Features to Add

1. **Create feature module** in `lib/features/`
2. **Define models** in `lib/shared/data/models/`
3. **Create repository** extending `BaseRepository`
4. **Implement use cases** extending `UseCase`
5. **Create BLoC/Cubit** extending `BaseCubit`
6. **Build UI** consuming state from BLoC/Cubit
7. **Register dependencies** in `core/di/get_it.dart`

## Current Features

### Authentication Infrastructure
- Secure token storage
- Session management
- Token auto-refresh

### Home
- Example BLoC implementation
- Example Cubit implementation
- Sample data fetching

## Testing Strategy

- Unit tests for repositories, use cases, cubits
- Widget tests for UI components
- Integration tests for critical flows
- Coverage target: >80%

## Security Considerations

- Sensitive data encrypted with flutter_secure_storage
- Tokens managed securely by TokenManager
- HTTPS enforced for all network calls
- Firebase AppCheck enabled
- Crashlytics filters sensitive data

## Performance Features

- Multi-layer caching (memory + disk)
- Request deduplication via cache interceptor
- Automatic retry with exponential backoff
- Offline queue for background sync
- Lazy initialization via GetIt

## Scalability

- Modular design supports large teams
- Feature-based folder structure
- Centralized dependency injection
- Reusable base classes minimize boilerplate
- Clear separation of concerns

## Next Steps

1. Review system architecture document for detailed design
2. Check code standards for implementation guidelines
3. Read individual module documentation for specific usage
4. Refer to project roadmap for development phases
