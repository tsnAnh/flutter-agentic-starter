# Module Implementation Guides

## Quick Navigation

1. [Networking Module](#networking-module)
2. [Caching Module](#caching-module)
3. [Authentication Module](#authentication-module)
4. [Firebase Module](#firebase-module)
5. [Analytics Module](#analytics-module)
6. [Connectivity Module](#connectivity-module)
7. [Design System Module](#design-system-module)
8. [Permissions Module](#permissions-module)

---

## Networking Module

**Location**: `lib/core/network/`

### Components

- **DioClient**: Main HTTP client
- **RetryInterceptor**: Automatic retry logic
- **CacheInterceptor**: HTTP caching
- **AuthenticationInterceptor**: Token injection
- **ConnectivityInterceptor**: Offline queue
- **LoggingInterceptor**: Request/response logging

### Setup

```dart
// In get_it.dart
void setupServiceLocator() {
  getIt.registerSingleton<DioClient>(DioClient());
}

// In API client
class DioClient {
  late Dio _dio;

  DioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.example.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    // Add interceptors in order
    _dio.interceptors.addAll([
      LoggingInterceptor(),
      AuthenticationInterceptor(),
      RetryInterceptor(),
      CacheInterceptor(),
      ConnectivityInterceptor(),
    ]);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }
}
```

### Usage in Repository

```dart
class UserRepositoryImpl implements UserRepository {
  final DioClient dio;

  UserRepositoryImpl(this.dio);

  @override
  Future<User> getUser(String id) async {
    final response = await dio.get('/users/$id');
    return UserDTO.fromJson(response.data).toEntity();
  }
}
```

### Customization

```dart
// Add custom interceptor
class CustomInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Modify request
    options.headers['X-Custom-Header'] = 'value';
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Modify response
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle error
    handler.next(err);
  }
}

// Register in DioClient
_dio.interceptors.add(CustomInterceptor());
```

---

## Caching Module

**Location**: `lib/core/cache/`

### Components

- **MemoryCache**: In-memory with TTL
- **DiskCache**: File-based persistent
- **CacheManager**: Coordination layer
- **CachedRepositoryMixin**: Easy integration

### Setup

```dart
// In get_it.dart
void setupServiceLocator() {
  getIt.registerSingleton<CacheManager>(
    CacheManager(
      memoryCache: MemoryCache(),
      diskCache: DiskCache(),
    ),
  );
}
```

### Usage in Repository

**Option 1: Use Mixin**
```dart
class UserRepositoryImpl with CachedRepositoryMixin implements UserRepository {
  final DioClient dio;

  UserRepositoryImpl(this.dio);

  @override
  Future<User> getUser(String id) async {
    const key = 'user_$id';

    // Try cache first
    if (hasCache(key)) {
      return getCache<User>(key)!;
    }

    // Fetch and cache
    final response = await dio.get('/users/$id');
    final user = UserDTO.fromJson(response.data).toEntity();

    setCache(key, user);
    return user;
  }

  Future<void> updateUser(User user) async {
    await dio.put('/users/${user.id}', data: user.toJson());
    // Invalidate cache
    invalidateCache('user_${user.id}');
  }
}
```

**Option 2: Manual Cache Management**
```dart
class UserRepositoryImpl implements UserRepository {
  final DioClient dio;
  final CacheManager cacheManager;

  UserRepositoryImpl(this.dio, this.cacheManager);

  @override
  Future<User> getUser(String id) async {
    const key = 'user_$id';

    // Try to get from cache
    final cached = cacheManager.get<User>(key);
    if (cached != null) {
      return cached;
    }

    // Fetch from API
    final response = await dio.get('/users/$id');
    final user = UserDTO.fromJson(response.data).toEntity();

    // Cache with 1-hour TTL
    cacheManager.set(key, user, duration: const Duration(hours: 1));

    return user;
  }
}
```

### Cache Policies

```dart
// Different TTLs for different data
abstract class CachePolicy {
  static const Duration userCache = Duration(hours: 1);
  static const Duration listCache = Duration(minutes: 30);
  static const Duration staticCache = Duration(days: 7);
}

// Usage
cacheManager.set(
  'users',
  userList,
  duration: CachePolicy.listCache,
);
```

### Cache Invalidation

```dart
// Invalidate single entry
cacheManager.invalidate('user_123');

// Invalidate by pattern
cacheManager.invalidateMatching((key) => key.startsWith('user_'));

// Clear all cache
cacheManager.clear();

// Clear memory but keep disk
cacheManager.clearMemory();
```

---

## Authentication Module

**Location**: `lib/core/auth/`

### Components

- **SecureStorageService**: Encrypted storage
- **TokenManager**: Token lifecycle
- **SessionManager**: User session
- **AuthenticationInterceptor**: Token injection

### Setup

```dart
// In get_it.dart
void setupServiceLocator() {
  getIt.registerSingleton<SecureStorageService>(SecureStorageService());
  getIt.registerSingleton<TokenManager>(TokenManager());
  getIt.registerSingleton<SessionManager>(SessionManager());
}
```

### Login Flow

```dart
class LoginCubit extends Cubit<DataState<User>> {
  final AuthenticateUseCase authenticate;
  final SessionManager sessionManager;

  LoginCubit({
    required this.authenticate,
    required this.sessionManager,
  }) : super(const DataStateInitial());

  Future<void> login(String email, String password) async {
    emit(const DataStateLoading());
    try {
      final user = await authenticate(email: email, password: password);

      // SessionManager stores tokens and user
      await sessionManager.initializeSession(user);

      emit(DataStateLoaded(user));
    } on Object catch (e, st) {
      emit(DataStateError(e.toString(), st));
    }
  }
}
```

### Token Management

```dart
class TokenManager {
  final SecureStorageService _storage = getIt<SecureStorageService>();

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write('access_token', accessToken);
    await _storage.write('refresh_token', refreshToken);
  }

  Future<String?> getAccessToken() {
    return _storage.read('access_token');
  }

  Future<String?> getRefreshToken() {
    return _storage.read('refresh_token');
  }

  Future<void> refreshTokens(String newAccessToken) async {
    await _storage.write('access_token', newAccessToken);
  }

  Future<void> clearTokens() async {
    await _storage.delete('access_token');
    await _storage.delete('refresh_token');
  }
}
```

### Logout

```dart
Future<void> logout() async {
  final sessionManager = getIt<SessionManager>();
  final tokenManager = getIt<TokenManager>();

  // Clear session
  await sessionManager.clearSession();

  // Clear tokens
  await tokenManager.clearTokens();

  // Clear cache
  getIt<CacheManager>().clear();

  // Navigate to login
  context.go('/login');
}
```

---

## Firebase Module

**Location**: `lib/core/firebase/`

### Setup in main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Setup services
  await FirebaseInitializer.instance.initialize();

  // Register in DI
  getIt.registerSingleton(CrashlyticsService());
  getIt.registerSingleton(PushNotificationService());

  runApp(const MyApp());
}
```

### Crashlytics

```dart
// Record caught exceptions
try {
  await someAsyncOperation();
} catch (e, st) {
  CrashlyticsService.recordError(e, st);
}

// Set custom data
CrashlyticsService.setCustomKey('user_id', userId);
CrashlyticsService.setCustomKey('app_version', appVersion);

// Log breadcrumbs
CrashlyticsService.log('User logged in successfully');
```

### Push Notifications

```dart
class PushNotificationService {
  static final instance = PushNotificationService._();

  PushNotificationService._() {
    _initialize();
  }

  void _initialize() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _handleMessage(RemoteMessage message) {
    final title = message.notification?.title ?? '';
    final body = message.notification?.body ?? '';

    // Route based on message data
    _routeToScreen(message.data);

    // Show notification
    _showNotification(title, body);
  }
}

// Register background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background notification
}
```

### Remote Config

```dart
class RemoteConfigService {
  static Future<void> initialize() async {
    final rc = FirebaseRemoteConfig.instance;

    // Set defaults
    await rc.setDefaults({
      'min_version': '1.0.0',
      'feature_enabled': true,
      'api_timeout': 30,
    });

    // Fetch latest values
    await rc.fetchAndActivate();
  }

  static String getString(String key) {
    return FirebaseRemoteConfig.instance.getString(key);
  }

  static bool getBool(String key) {
    return FirebaseRemoteConfig.instance.getBool(key);
  }

  static int getInt(String key) {
    return FirebaseRemoteConfig.instance.getInt(key);
  }
}

// Usage
bool featureEnabled = RemoteConfigService.getBool('feature_enabled');
if (featureEnabled) {
  // Show new feature
}
```

---

## Analytics Module

**Location**: `lib/core/analytics/`

### Setup

```dart
// In get_it.dart
void setupServiceLocator() {
  getIt.registerSingleton<AnalyticsService>(
    CompositeAnalyticsProvider([
      FirebaseAnalyticsProvider(),
      PostHogAnalyticsProvider(apiKey: 'ph_xxx'),
    ]),
  );
}
```

### Page View Tracking

```dart
class MyScreen extends StatefulWidget with AnalyticsMixin {
  @override
  void initState() {
    super.initState();
    logPageView('my_screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Screen')),
    );
  }
}
```

### Event Tracking

```dart
class MyButton extends StatelessWidget {
  const MyButton();

  void _onPressed() {
    logEvent('button_tapped', {
      'button_id': 'submit',
      'section': 'form',
      'timestamp': DateTime.now().toString(),
    });

    // Perform action
    _submitForm();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _onPressed,
      child: const Text('Submit'),
    );
  }
}
```

### Custom Events

```dart
// Track user actions
logEvent('user_signup', {
  'source': 'google',
  'has_referral': true,
});

logEvent('purchase_complete', {
  'amount': 99.99,
  'currency': 'USD',
  'items_count': 3,
});

logEvent('search_performed', {
  'query': 'flutter',
  'results_count': 42,
});
```

---

## Connectivity Module

**Location**: `lib/core/connectivity/`

### Setup

```dart
// In get_it.dart
void setupServiceLocator() {
  getIt.registerSingleton<ConnectivityService>(ConnectivityService());
  getIt.registerSingleton<ConnectivityCubit>(
    ConnectivityCubit(getIt<ConnectivityService>()),
  );
  getIt.registerSingleton<OfflineQueueService>(OfflineQueueService());
}
```

### Monitor Connectivity

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, bool>(
      builder: (context, isOnline) {
        return Column(
          children: [
            if (!isOnline)
              const Banner(
                message: 'Offline',
                location: BannerLocation.topEnd,
              ),
            // Rest of screen
          ],
        );
      },
    );
  }
}
```

### Offline Queue

```dart
class OfflineAwareRepository with OfflineAwareMixin {
  final DioClient dio;

  OfflineAwareRepository(this.dio);

  Future<void> saveItem(Item item) async {
    if (!isOnline) {
      // Queue for later
      await queueRequest(
        method: 'POST',
        path: '/items',
        data: item.toJson(),
      );
      return;
    }

    // Save immediately
    await dio.post('/items', data: item.toJson());
  }
}
```

---

## Design System Module

**Location**: `lib/core/design_system/`

### Color Tokens

```dart
extension AppColorsExtension on ThemeData {
  AppColors get colors => extension<AppColors>()!;
}

class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color secondary;
  final Color error;
  final Color surface;
  final Color onPrimary;

  const AppColors({
    required this.primary,
    required this.secondary,
    required this.error,
    required this.surface,
    required this.onPrimary,
  });

  @override
  AppColors copyWith({
    Color? primary,
    Color? secondary,
    Color? error,
    Color? surface,
    Color? onPrimary,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      error: error ?? this.error,
      surface: surface ?? this.surface,
      onPrimary: onPrimary ?? this.onPrimary,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(
    ThemeExtension<AppColors>? other,
    double t,
  ) {
    // For theme transitions
    return this;
  }
}
```

### Spacing Scale

```dart
class AppSpacing extends ThemeExtension<AppSpacing> {
  final double xs;   // 4
  final double sm;   // 8
  final double md;   // 12
  final double lg;   // 16
  final double xl;   // 24
  final double xxl;  // 32

  const AppSpacing({
    this.xs = 4,
    this.sm = 8,
    this.md = 12,
    this.lg = 16,
    this.xl = 24,
    this.xxl = 32,
  });

  @override
  AppSpacing copyWith({/* ... */}) => this;

  @override
  ThemeExtension<AppSpacing> lerp(
    ThemeExtension<AppSpacing>? other,
    double t,
  ) =>
      this;
}

// Usage
Padding(
  padding: EdgeInsets.all(context.theme.extension<AppSpacing>()!.lg),
  child: Text('Padded text'),
)
```

### Typography

```dart
class AppTypography extends ThemeExtension<AppTypography> {
  final TextStyle headline1;
  final TextStyle headline2;
  final TextStyle body1;
  final TextStyle body2;
  final TextStyle button;
  final TextStyle caption;

  const AppTypography({
    required this.headline1,
    required this.headline2,
    required this.body1,
    required this.body2,
    required this.button,
    required this.caption,
  });
}

// Usage
Text(
  'Hello',
  style: context.theme.extension<AppTypography>()!.headline1,
)
```

---

## Permissions Module

**Location**: `lib/core/permissions/`

### Setup

```dart
// In get_it.dart
void setupServiceLocator() {
  getIt.registerSingleton<PermissionService>(
    PermissionHandlerImpl(),
  );
  getIt.registerSingleton<PermissionCubit>(
    PermissionCubit(getIt<PermissionService>()),
  );
}
```

### Request Permission

```dart
class CameraScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionCubit, PermissionState>(
      builder: (context, state) => switch (state) {
        PermissionGranted() => const CameraWidget(),
        PermissionDenied() => Center(
          child: Column(
            children: [
              const Text('Camera permission required'),
              ElevatedButton(
                onPressed: () => context.read<PermissionCubit>()
                    .requestPermission(Permission.camera),
                child: const Text('Request Permission'),
              ),
            ],
          ),
        ),
        PermissionPermanentlyDenied() => const PermissionSettingsDialog(),
        _ => const LoadingWidget(),
      },
    );
  }
}
```

### Multiple Permissions

```dart
Future<bool> requestCameraAndMicrophone() async {
  final permissionCubit = getIt<PermissionCubit>();

  final cameraGranted = await permissionCubit.requestPermission(Permission.camera);
  final micGranted = await permissionCubit.requestPermission(Permission.microphone);

  return cameraGranted && micGranted;
}
```

---

## Summary

Each module is designed to be:
- **Independent**: Can be used separately
- **Composable**: Works well with other modules
- **Testable**: Easy to mock and test
- **Documented**: Clear usage examples
- **Extensible**: Easy to customize or extend

For more details, see the module source code in `lib/core/[module-name]/`.

