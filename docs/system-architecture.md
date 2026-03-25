# System Architecture

## Architecture Overview

Flutter BLoC Base implements **Clean Architecture** combined with **BLoC Pattern** for state management. This ensures scalability, testability, and maintainability across large teams.

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                           │
│  (UI Widgets, Screens, State Management - BLoC/Cubit)          │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │ (Dependencies)
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                                │
│  (Business Logic, Entities, Abstract Repositories, Use Cases)   │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │ (Implements)
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DATA LAYER                                 │
│  (Repositories, Data Sources, Models, Caching)                 │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │ (Uses)
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│               INFRASTRUCTURE LAYER                              │
│  (HTTP Client, Storage, Firebase, Permissions, Analytics)      │
└─────────────────────────────────────────────────────────────────┘
```

## Detailed Component Architecture

### 1. Presentation Layer

**Location**: `lib/features/*/` and `lib/shared/widgets/`

**Components**:
- **Screens**: Feature UI entry points
- **BLoCs**: Event-driven state management
- **Cubits**: Simple state management
- **Widgets**: Reusable UI components

**State Management Flow**:
```
User Action (Tap, Input)
  ↓
Widget calls Cubit/BLoC method
  ↓
Cubit/BLoC emits new state
  ↓
BlocListener/BlocBuilder updates UI
  ↓
UI reflects new state
```

**Example Cubit Pattern**:
```dart
class HomeCubit extends BaseCubit<List<Item>> {
  final GetItemsUseCase getItems;

  HomeCubit(this.getItems) : super();

  @override
  Future<List<Item>> fetch() => getItems();
}
```

### 2. Domain Layer

**Location**: `lib/features/*/models/` (entities) and use cases

**Responsibilities**:
- Define business entities
- Declare abstract repositories
- Implement use cases
- No knowledge of frameworks

**Key Classes**:
- **UseCase<Input, Output>**: Abstract base for business logic
- **Entity**: Domain model (pure Dart class)
- **Repository**: Abstract interface for data access

**Example**:
```dart
abstract class GetItemsUseCase extends UseCase<void, List<Item>> {
  @override
  Future<List<Item>> call([void input]) async {
    final repo = getIt<ItemRepository>();
    return repo.getItems();
  }
}
```

### 3. Data Layer

**Location**: `lib/shared/data/` and `lib/features/*/data/`

**Responsibilities**:
- Implement repositories
- Define DTOs (Data Transfer Objects)
- Manage data sources (remote, local, cache)
- Handle data transformation

**Key Classes**:
- **Repository Implementation**: Concrete repository extending BaseRepository
- **DTO**: Model for API responses
- **CachedRepositoryMixin**: Adds caching to repositories

**Example**:
```dart
class ItemRepositoryImpl extends BaseRepository
    with CachedRepositoryMixin
    implements ItemRepository {

  final DioClient dio;

  @override
  Future<List<Item>> getItems() async {
    final key = 'items';

    // Try cache first
    if (hasCache(key)) {
      return getCache(key);
    }

    // Fetch from API
    final response = await dio.get('/items');
    final items = (response.data as List)
        .map((json) => ItemDTO.fromJson(json).toEntity())
        .toList();

    // Cache result
    setCache(key, items);

    return items;
  }
}
```

### 4. Infrastructure Layer

**Core Modules** (15 specialized subsystems):

#### 4.1 Networking Module
**Components**:
- **DioClient**: HTTP client configuration
- **Interceptors**: 5 specialized interceptors
  - RetryInterceptor: Exponential backoff retry logic
  - CacheInterceptor: HTTP-level caching
  - ConnectivityInterceptor: Offline queue
  - AuthenticationInterceptor: Token injection
  - LoggingInterceptor: Request/response logging

**Request Flow**:
```
User Request
  ↓
[DioClient]
  ↓ (Pass through interceptors)
[RetryInterceptor] → Handle failures with retry
  ↓
[ConnectivityInterceptor] → Queue if offline
  ↓
[AuthenticationInterceptor] → Attach token
  ↓
[CacheInterceptor] → Check cache
  ↓
[LoggingInterceptor] → Log request
  ↓
[HTTP Request]
  ↓
[Response]
  ↓
[LoggingInterceptor] → Log response
  ↓
[CacheInterceptor] → Cache response
  ↓
Back to Caller
```

#### 4.2 Caching Module
**Architecture**:
```
┌─ Memory Cache (Fast, volatile)
│   └─ TTL-based expiration
│   └─ LRU eviction policy
│
Cubit/Repository
│   ↓
├─ Cache Manager (Coordination)
│   ├─ Query hierarchy (memory → disk)
│   └─ Write strategy (memory + disk)
│
└─ Disk Cache (Persistent)
    └─ File-based storage
    └─ JSON serialization
```

**Usage**:
```dart
class MyRepository with CachedRepositoryMixin {
  Future<Data> getData() {
    const key = 'my_data';

    if (hasCache(key)) {
      return Future.value(getCache<Data>(key));
    }

    return _fetchFromApi().then((data) {
      setCache(key, data);
      return data;
    });
  }
}
```

#### 4.3 Connectivity Module
**State Management**:
```
ConnectivityService
  ↓ (Monitors: WiFi, Mobile, None)
  ↓
ConnectivityCubit
  ↓ (Emits: online, offline)
  ↓
UI/Repositories
  ↓
OfflineQueueService (if offline)
  └─ Queues requests for retry when online
```

**Offline-First Strategy**:
1. Detect connectivity loss
2. Queue requests in OfflineQueueService
3. Persist queue to disk
4. Retry when connectivity restored
5. Emit success/failure to UI

#### 4.4 Authentication Module
**Token Lifecycle**:
```
User Login (Credentials)
  ↓
[AuthenticationInterceptor] Request login endpoint
  ↓
[TokenManager] Store access + refresh tokens
  ↓
[SecureStorageService] Encrypt and persist
  ↓
[SessionManager] Initialize user session
  ↓
[AuthenticationInterceptor] Auto-inject token in requests
  ↓
Token Expiration Detected
  ↓
[TokenManager] Refresh token silently
  ↓
[SecureStorageService] Update persisted tokens
  ↓
Retry Original Request
```

**Secure Storage**:
```
Credentials
  ↓
[SecureStorageService]
  ├─ iOS: Keychain
  ├─ Android: Encrypted SharedPreferences
  └─ Web: Secure storage mechanism
```

#### 4.5 Firebase Module
**Services**:
```
┌─ FirebaseInitializer
│  └─ Configure Firebase on app startup
│
├─ CrashlyticsService
│  ├─ Report uncaught exceptions
│  ├─ Log breadcrumbs
│  └─ Attach custom keys
│
├─ PushNotificationService
│  ├─ Register FCM token
│  ├─ Handle notifications
│  └─ Route to appropriate handler
│
├─ RemoteConfigService
│  ├─ Fetch remote flags
│  ├─ Cache locally
│  └─ Enable feature flags
│
└─ AppCheckService
   └─ Validate app authenticity (abuse prevention)
```

**Integration**:
```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseInitializer.instance.initialize();

  // Register services
  getIt.registerSingleton(CrashlyticsService());
  getIt.registerSingleton(PushNotificationService());

  runApp(MyApp());
}

// In code
CrashlyticsService.recordError(exception, stackTrace);
PushNotificationService.instance.onMessage.listen((message) {
  // Handle notification
});
```

#### 4.6 Analytics Module
**Multi-Provider Architecture**:
```
┌─ CompositeAnalyticsProvider
│  ├─ FirebaseAnalyticsProvider
│  ├─ PostHogAnalyticsProvider
│  └─ Future custom providers...
│
└─ AnalyticsMixin (Widget-level tracking)
   ├─ logEvent('page_view')
   ├─ logEvent('button_tap')
   └─ logEvent('custom_event')
```

**Usage**:
```dart
class MyScreen extends StatefulWidget with AnalyticsMixin {
  @override
  void initState() {
    super.initState();
    logPageView('my_screen');
  }

  void onButtonTap() {
    logEvent('button_tapped', {'button_id': 'submit'});
  }
}
```

#### 4.7 Permissions Module
**Permission Flow**:
```
Request Permission
  ↓
[PermissionService] → Check status
  ↓
Status = Granted? → Yes → Return true
Status = Denied? → No → Request
  ↓
[PermissionCubit] Emit granted/denied
  ↓
UI reacts to permission state
```

#### 4.8 Router & Deep Linking
**Deep Link Resolution**:
```
Deep Link (e.g., app://items/123)
  ↓
[DeepLinkHandler] Parse and extract params
  ↓
[RouteParams] Type-safe param holder
  ↓
[Router] Navigate to corresponding screen
```

#### 4.9 Design System Module
**Token Hierarchy**:
```
ThemeExtension
├─ Colors (semantic + custom)
├─ Spacing (4, 8, 12, 16, 24, 32...)
├─ Radius (2, 4, 8, 12, 16, 20...)
├─ Shadows (elevation 1-24)
├─ Typography (headline1, body1, button...)
└─ Durations (fast, normal, slow)
```

**Access**:
```dart
// In widgets
final colors = context.theme.extension<AppColors>()!;
final spacing = context.theme.extension<AppSpacing>()!;

// Create consistent UI
Container(
  padding: EdgeInsets.all(spacing.md), // 16
  decoration: BoxDecoration(
    color: colors.primary,
    borderRadius: BorderRadius.circular(spacing.lg), // 8
  ),
)
```

#### 4.10 Lifecycle Module
**App State Transitions**:
```
App Launched
  ↓
[AppLifecycleObserver] Register listener
  ↓
User leaves app → paused state
  ↓
[AppUpdateChecker] Check for updates
  ↓
User returns → resumed state
  ↓
[OfflineQueueService] Retry queued requests
```

#### 4.11 Logger Module
**Logging Strategy**:
```
Development (DebugLogger)
├─ Full stack traces
├─ All log levels
└─ Pretty formatted

Production (ProductionLogger)
├─ Filtered levels (warn, error)
├─ Sensitive data redacted
└─ Crashlytics integration
```

#### 4.12 Extensions Module
**Available Extensions**:
- **StringExtensions**: `'hello'.toCamelCase()`, `'hello-world'.toPascalCase()`
- **DateTimeExtensions**: `now.formatted()`, `now.isToday`
- **IterableExtensions**: `list.firstOrNull()`, `list.mapNotNull()`
- **NumExtensions**: `1000.formatted()` → "1,000"
- **WidgetExtensions**: Padding, sizing shortcuts
- **FutureExtensions**: Timeout, error handling
- **ContextExtensions**: Media query shortcuts

#### 4.13 Utilities Module
**Utility Categories**:
- **ColorUtils**: Parsing, conversion, brightness detection
- **DateUtils**: Formatting, parsing, relative dates
- **StringUtils**: Validation, transformation, truncation
- **NumberUtils**: Formatting, rounding, range checking
- **ResponseUtils**: Screen size, breakpoints, orientation
- **SnackbarUtils**: Quick toast notifications
- **UrlUtils**: Validation, parameter extraction
- **Debouncer/Throttler**: Event rate limiting

#### 4.14 Permissions Module (Advanced)
**Platform-Specific Handling**:
```
iOS:
├─ Microphone
├─ Camera
└─ Location

Android:
├─ Location
├─ Calendar
├─ Contacts
└─ Storage

Web:
└─ Limited permission model
```

#### 4.15 Dependency Injection
**Service Registration Pattern**:
```dart
// In get_it.dart
void setupServiceLocator() {
  // Singletons (one instance for app lifetime)
  getIt.registerSingleton<ApiClient>(DioApiClient());

  // Lazy singletons (created on first access)
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<ApiClient>())
  );

  // Factories (new instance each time)
  getIt.registerFactory<LoginCubit>(
    () => LoginCubit(getIt<AuthUseCase>())
  );
}

// In features
final authRepo = getIt<AuthRepository>();
final cubit = getIt<LoginCubit>();
```

## Data Flow Examples

### Example 1: Fetch and Display Items

```
User opens HomeScreen
  ↓
HomeCubit.load() called
  ↓
emit(DataStateLoading())
  ↓
fetch() calls GetItemsUseCase
  ↓
UseCase calls ItemRepository.getItems()
  ↓
Repository checks CachedRepositoryMixin.hasCache('items')
  ↓
Cache found? → Yes → Return cached data
         → No → DioClient.get('/api/items')
  ↓
[RetryInterceptor] Retries on failure
[ConnectivityInterceptor] Queues if offline
[AuthenticationInterceptor] Adds auth header
[CacheInterceptor] Caches response
  ↓
Response received
  ↓
DTO.fromJson() converts to Entity
  ↓
setCache('items', entities)
  ↓
Return entities to HomeCubit
  ↓
emit(DataStateLoaded(entities))
  ↓
BlocBuilder rebuilds UI
  ↓
ListView displays items
```

### Example 2: Offline Request Handling

```
User taps submit while offline
  ↓
Repository.saveItem() called
  ↓
[ConnectivityInterceptor] Detects offline
  ↓
OfflineQueueService.queue(request)
  ↓
Persist queue to disk
  ↓
emit(DataStateLoaded(optimistic_data))
  ↓
[ConnectivityCubit] emits online
  ↓
OfflineQueueService detects connectivity
  ↓
Restore queue from disk
  ↓
Retry each queued request
  ↓
[AuthenticationInterceptor] Refreshes token if needed
  ↓
Request succeeds
  ↓
Remove from queue
  ↓
emit(success_state)
```

### Example 3: Token Refresh

```
API request with expired token
  ↓
[Response 401 Unauthorized]
  ↓
[AuthenticationInterceptor] Detects 401
  ↓
TokenManager.refreshToken()
  ↓
POST /auth/refresh with refresh_token
  ↓
[Response] { access_token, refresh_token }
  ↓
TokenManager stores new tokens
  ↓
SecureStorageService persists tokens
  ↓
Retry original request with new token
  ↓
[Response 200 OK]
  ↓
Return data to caller
```

## Dependency Graph

```
Features
├── Home Feature
│   ├── HomeCubit
│   └── GetItemsUseCase
│
└── Login Feature
    ├── LoginCubit
    └── AuthenticateUseCase

Shared Layer
├── ItemRepository (abstract)
├── AuthRepository (abstract)
├── FormValidation
└── Widgets

Core Infrastructure
├── Network Layer
│   ├── DioClient
│   ├── Interceptors (5 types)
│   └── StatusCode handlers
│
├── Cache Layer
│   ├── MemoryCache
│   ├── DiskCache
│   └── CacheManager
│
├── Auth Layer
│   ├── SecureStorageService
│   ├── TokenManager
│   └── SessionManager
│
├── Connectivity Layer
│   ├── ConnectivityService
│   ├── OfflineQueueService
│   └── ConnectivityCubit
│
├── Firebase Layer
│   ├── CrashlyticsService
│   ├── PushNotificationService
│   ├── RemoteConfigService
│   └── AppCheckService
│
├── Analytics Layer
│   ├── CompositeAnalyticsProvider
│   ├── FirebaseAnalyticsProvider
│   └── PostHogAnalyticsProvider
│
├── Design System (Tokens)
│   ├── Colors
│   ├── Spacing
│   ├── Typography
│   ├── Radius
│   ├── Shadows
│   └── Durations
│
├── Permissions Layer
│   ├── PermissionService
│   └── PermissionCubit
│
├── Router & Deep Linking
│   ├── DeepLinkHandler
│   └── RouteParams
│
├── Lifecycle Management
│   ├── AppLifecycleObserver
│   └── AppUpdateChecker
│
└── Utilities
    ├── Extensions (8 types)
    ├── Utils (10 types)
    ├── Logger
    └── Theme
```

## Error Handling Strategy

```
Error Occurrence
  ↓
[Try-Catch] Capture exception
  ↓
[DataStateError] Emit error state
  ↓
[ErrorScreen] Display user-friendly message
  ↓
[CrashlyticsService] Log to Crashlytics
  ↓
[Logger] Log details for debugging
  ↓
[Analytics] Track error event
  ↓
[UI] Offer retry action
```

## Thread Safety & Concurrency

- **BLoC**: Single-threaded event processing (internally sequential)
- **Dio**: Thread-safe HTTP client (handles concurrent requests)
- **Cache**: Thread-safe via Mutex locks (dart:isolate compatible)
- **Storage**: Atomic writes via flutter_secure_storage
- **Database**: (If added) Use drift or hive for thread safety

## Performance Considerations

1. **Caching**: Multi-layer reduces API calls by 60-80%
2. **Lazy Loading**: GetIt lazy singletons reduce startup time
3. **Request Deduplication**: Cache interceptor prevents duplicate requests
4. **Offline Queue**: Batches requests for efficient retry
5. **Image Caching**: Implement with flutter_cache_manager
6. **Pagination**: BasePaginatedCubit handles incremental loading
7. **Memory**: Implement image streaming for large lists

## Security Architecture

```
User Input
  ↓
[Validation] FormZ validation
  ↓
[Sanitization] Remove harmful content
  ↓
[Encryption] Encrypt sensitive data
  ↓
Network Request
  ↓
[HTTPS] SSL/TLS encryption
  ↓
[AuthenticationInterceptor] Secure token handling
  ↓
[AppCheck] Verify app authenticity
  ↓
Backend (Trust, verify, don't expose)
```

## Testing Architecture

```
Unit Tests
├── Repository tests (mock API)
├── UseCase tests (mock repositories)
├── Cubit tests (mock use cases)
└── Widget tests (mock cubits)

Integration Tests
├── Full feature workflows
├── Navigation flows
└── API integration (staging environment)

E2E Tests (Optional)
└── Critical user journeys (production-like)
```

## Scaling Strategy

1. **Horizontal**: Add features without modifying core
2. **Vertical**: Add interceptors/services to core infrastructure
3. **Modular**: Extract shared logic to packages
4. **Team**: Clear file ownership boundaries per feature

