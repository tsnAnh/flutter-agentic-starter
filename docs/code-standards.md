# Code Standards & Implementation Guidelines

## Overview

This document defines coding standards, patterns, and conventions for the Flutter BLoC Base project. All developers must adhere to these standards to maintain consistency and quality.

## File Organization

### Naming Conventions

**Dart Files**: Use `snake_case` with descriptive names
```
✓ Good
user_repository.dart
authentication_service.dart
login_cubit.dart
data_state.dart

✗ Bad
UserRepository.dart
authService.dart
loginCubit.dart
state.dart
```

**Classes & Types**: Use `PascalCase`
```dart
class UserRepository { }
class AuthenticationService { }
class LoginCubit { }
abstract class UseCase { }
```

**Variables & Functions**: Use `camelCase`
```dart
final userName = 'John';
void loadUserData() { }
Future<User> fetchUser() async { }
```

**Constants**: Use `camelCase` (not SCREAMING_SNAKE_CASE)
```dart
const defaultTimeout = Duration(seconds: 30);
const maxRetries = 3;
const apiBaseUrl = 'https://api.example.com';
```

### Directory Structure

```
lib/
├── core/
│   ├── [module]/
│   │   ├── *.dart (implementations)
│   │   └── [module].dart (barrel export)
│   ├── app_bloc_observer.dart
│   └── error.dart
│
├── features/
│   └── [feature_name]/
│       ├── bloc/ (if using BLoC)
│       │   ├── *_bloc.dart
│       │   ├── *_event.dart
│       │   ├── *_state.dart
│       │   └── bloc.dart (barrel export)
│       ├── cubit/ (if using Cubit)
│       │   ├── *_cubit.dart
│       │   └── cubit.dart (barrel export)
│       ├── data/
│       │   ├── datasources/
│       │   ├── repositories/
│       │   └── data.dart
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/ (abstract)
│       │   ├── usecases/
│       │   └── domain.dart
│       ├── presentation/
│       │   ├── pages/
│       │   ├── widgets/
│       │   └── presentation.dart
│       └── [feature_name].dart (main export)
│
└── shared/
    ├── blocs/
    ├── data/
    ├── forms/
    ├── i18n/
    ├── services/
    ├── widgets/
    └── shared.dart
```

### Generated Code

- Never manually edit build_runner generated files, including `*.g.dart`, `*.freezed.dart`, `*.config.dart`, or files marked `GENERATED CODE - DO NOT MODIFY BY HAND`.
- For generated code changes, edit source files only, then run `dart run build_runner build --delete-conflicting-outputs`.

## Code Patterns

### 1. State Management (DataState Pattern)

Use sealed `DataState<T>` for all async operations:

```dart
// ✓ Good: Handles all states
BlocBuilder<MyDataCubit, DataState<MyData>>(
  builder: (context, state) => switch (state) {
    DataStateInitial() => const SizedBox.shrink(),
    DataStateLoading() => const LoadingWidget(),
    DataStateLoaded(:final data) => MyWidget(data: data),
    DataStateError(:final message) => ErrorWidget(message: message),
  },
);

// ✗ Bad: Doesn't handle all states
BlocBuilder<MyDataCubit, DataState<MyData>>(
  builder: (context, state) {
    if (state is DataStateLoaded) {
      return MyWidget(data: state.data);
    }
    return SizedBox.shrink();
  },
);
```

### 2. Repository Pattern

All repositories should extend `BaseRepository`:

```dart
// ✓ Good
abstract class UserRepository extends BaseRepository {
  Future<User> getUser(String id);
  Future<void> updateUser(User user);
}

class UserRepositoryImpl extends UserRepository
    with CachedRepositoryMixin
    implements UserRepository {

  final DioClient dio;

  UserRepositoryImpl(this.dio);

  @override
  Future<User> getUser(String id) async {
    const key = 'user_$id';

    if (hasCache(key)) {
      return getCache<User>(key)!;
    }

    final response = await dio.get('/users/$id');
    final user = UserDTO.fromJson(response.data).toEntity();

    setCache(key, user);
    return user;
  }

  @override
  Future<void> updateUser(User user) async {
    await dio.put('/users/${user.id}', data: user.toJson());
    invalidateCache('user_${user.id}');
  }
}

// ✗ Bad: Doesn't use BaseRepository
class UserRepositoryImpl implements UserRepository {
  // No caching support, no structured error handling
}
```

### 3. Use Cases

Implement business logic in use cases:

```dart
// ✓ Good
abstract class GetUserUseCase extends UseCase<String, User> {
  @override
  Future<User> call(String userId) async {
    final repository = getIt<UserRepository>();
    final user = await repository.getUser(userId);

    if (user.isInactive) {
      throw UserInactiveException();
    }

    return user;
  }
}

// ✗ Bad: Use case has no input/output
class GetUserUseCase {
  Future<User> getUser() async {
    // ...
  }
}
```

### 4. Cubit Pattern

Use `BaseCubit` for simple data fetching:

```dart
// ✓ Good
class UserCubit extends BaseCubit<User> {
  final GetUserUseCase getUser;

  UserCubit({required this.getUser});

  @override
  Future<User> fetch() => getUser();

  // Additional methods for mutations
  Future<void> updateUser(User user) async {
    emit(const DataStateLoading());
    try {
      await getIt<UserRepository>().updateUser(user);
      final updated = await fetch();
      emit(DataStateLoaded(updated));
    } on Object catch (e, st) {
      emit(DataStateError(e.toString(), st));
    }
  }
}

// Usage in Widget
BlocBuilder<UserCubit, DataState<User>>(
  builder: (context, state) => switch (state) {
    DataStateLoaded(:final data) => Text(data.name),
    _ => const SizedBox.shrink(),
  },
);
```

### 5. BLoC Pattern

Use BLoCs for complex state management:

```dart
// ✓ Good
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthenticateUseCase authenticate;

  LoginBloc({required this.authenticate}) : super(const LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginReset>(_onLoginReset);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());
    try {
      final user = await authenticate(
        email: event.email,
        password: event.password,
      );
      emit(LoginSuccess(user: user));
    } on AuthenticationException catch (e) {
      emit(LoginFailure(message: e.message));
    }
  }

  Future<void> _onLoginReset(
    LoginReset event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginInitial());
  }
}
```

### 6. Dependency Injection

Register services in a single location:

```dart
// core/di/get_it.dart

void setupServiceLocator() {
  // Singletons (app-wide single instance)
  getIt.registerSingleton<DioClient>(DioClient());
  getIt.registerSingleton<ConnectivityService>(ConnectivityService());

  // Lazy singletons (created on first access)
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt<DioClient>()),
  );

  // Factories (new instance each time)
  getIt.registerFactory<UserCubit>(
    () => UserCubit(getUser: getIt<GetUserUseCase>()),
  );
}

// Usage
final userRepository = getIt<UserRepository>();
final userCubit = getIt<UserCubit>();
```

### 7. Error Handling

Create custom exception classes:

```dart
// ✓ Good
abstract class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(super.message);
}

class ValidationException extends AppException {
  ValidationException(super.message);
}

// Handle in repositories
Future<User> getUser(String id) async {
  try {
    final response = await dio.get('/users/$id');
    return UserDTO.fromJson(response.data).toEntity();
  } on DioException catch (e) {
    throw NetworkException('Failed to fetch user: ${e.message}');
  } catch (e) {
    throw AppException('Unexpected error: $e');
  }
}

// ✗ Bad: Generic error handling
Future<User> getUser(String id) async {
  final response = await dio.get('/users/$id');
  return UserDTO.fromJson(response.data).toEntity();
  // No error handling
}
```

### 8. Widget Composition

Prefer composition over inheritance:

```dart
// ✓ Good: Composable, testable
class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onTap;

  const UserCard({
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(context.spacing.lg),
          child: Column(
            children: [
              Text(user.name, style: context.typography.headline),
              Text(user.email, style: context.typography.body),
            ],
          ),
        ),
      ),
    );
  }
}

// ✗ Bad: Inheritance, tightly coupled
class UserCard extends StatefulWidget {
  const UserCard(this.userId);
  final String userId;

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  late UserRepository _repository;
  late User _user;

  @override
  void initState() {
    super.initState();
    _repository = getIt<UserRepository>();
    _loadUser();
  }

  void _loadUser() {
    // Direct API call in widget
  }

  @override
  Widget build(BuildContext context) {
    // Tightly coupled to data loading
    return Text(_user.name);
  }
}
```

## Code Quality Standards

### Comments

Write comments that explain **why**, not **what**:

```dart
// ✓ Good: Explains intent
// Retry with exponential backoff to handle transient failures
// (quota errors, temporary unavailability)
Future<T> _retryWithBackoff<T>(Future<T> Function() fn) async {
  // ...
}

// ✗ Bad: Restates code
// Increment counter
counter++;

// ✗ Bad: Obvious from code
// Set user to loaded
state = UserLoaded(user);
```

### Code Length

Keep functions small and focused:

```dart
// ✓ Good: Single responsibility
Future<void> _handleLogin(LoginSubmitted event) async {
  final isValid = _validateEmail(event.email);
  if (!isValid) {
    emit(LoginFailure(message: 'Invalid email'));
    return;
  }

  emit(const LoginLoading());
  final result = await _authenticate(event.email, event.password);

  result.fold(
    (error) => emit(LoginFailure(message: error)),
    (user) => emit(LoginSuccess(user: user)),
  );
}

private Future<void> _authenticate(String email, String password) {
  // Focused implementation
}

// ✗ Bad: Doing too much
Future<void> handleLogin(LoginEvent event) async {
  // Validation logic
  // Authentication logic
  // State emission
  // Error handling
  // Retry logic
  // All in one 100+ line function
}
```

### Nullability

Use non-nullable types by default:

```dart
// ✓ Good: Non-nullable by default
class User {
  final String id;
  final String name;
  final String? middleName; // Explicitly nullable
  final String email;
}

final user = User(
  id: '123',
  name: 'John',
  email: 'john@example.com',
);

// ✗ Bad: Nullable when not needed
class User {
  String? id;
  String? name;
  String? email;
}
```

### Immutability

Use `final` and const classes:

```dart
// ✓ Good: Immutable data classes
class User {
  final String id;
  final String name;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.email,
  });
}

// ✗ Bad: Mutable
class User {
  String id;
  String name;
  String email;

  User(this.id, this.name, this.email);
}
```

### Testing

Every module should have tests:

```
lib/core/cache/cache_manager.dart
test/core/cache/cache_manager_test.dart

lib/features/home/cubit/home_cubit.dart
test/features/home/cubit/home_cubit_test.dart
```

**Test naming**:
```dart
void main() {
  group('UserRepository', () {
    group('getUser', () {
      test('returns User when API call succeeds', () async {
        // Arrange
        final mockDio = MockDioClient();
        final repository = UserRepositoryImpl(mockDio);

        // Act
        final user = await repository.getUser('123');

        // Assert
        expect(user.id, '123');
      });

      test('throws NetworkException when API call fails', () async {
        // Arrange, Act, Assert
      });
    });
  });
}
```

## Async/Await Best Practices

```dart
// ✓ Good: Async/await for readability
Future<User> getUser(String id) async {
  try {
    final response = await dio.get('/users/$id');
    return UserDTO.fromJson(response.data).toEntity();
  } on DioException catch (e) {
    throw NetworkException(e.message ?? 'Network error');
  }
}

// ✓ Good: Futures with .then() for simple chains
repository.getUser('123')
    .then((user) => updateUI(user))
    .catchError((error) => showError(error));

// ✗ Bad: Callback hell
void getUser(String id, Function(User) onSuccess, Function(String) onError) {
  dio.get('/users/$id').then((response) {
    try {
      final user = UserDTO.fromJson(response.data).toEntity();
      onSuccess(user);
    } catch (e) {
      onError(e.toString());
    }
  }).catchError((error) {
    onError(error.toString());
  });
}
```

## Sealed Classes & Pattern Matching

Use sealed classes for exhaustive pattern matching:

```dart
// ✓ Good: Compiler ensures all cases handled
sealed class DataState<T> {
  const DataState();
}

final class DataStateInitial<T> extends DataState<T> { }
final class DataStateLoading<T> extends DataState<T> { }
final class DataStateLoaded<T> extends DataState<T> {
  final T data;
  DataStateLoaded(this.data);
}

// Compiler error if you miss a case
final result = switch (state) {
  DataStateInitial() => 'Not loaded',
  DataStateLoading() => 'Loading',
  DataStateLoaded(:final data) => 'Got: $data',
  // Missing DataStateError => compiler error!
};

// ✗ Bad: If/else allows missing cases
if (state is DataStateLoaded) {
  // What about DataStateError?
}
```

## Extension Methods

Use extensions for utility methods:

```dart
// ✓ Good: Extends existing types
extension StringFormatting on String {
  String toCamelCase() {
    // Implementation
  }

  String toPascalCase() {
    // Implementation
  }

  bool isValidEmail() {
    // Implementation
  }
}

// Usage
'hello world'.toCamelCase(); // 'helloWorld'
'test@example.com'.isValidEmail(); // true

// ✗ Bad: Utility class
class StringUtils {
  static String toCamelCase(String input) { }
  static String toPascalCase(String input) { }
  static bool isValidEmail(String email) { }
}

StringUtils.toCamelCase('hello world');
```

## Linting & Formatting

```bash
# Format code
dart format lib/

# Analyze code
dart analyze lib/

# Run linter
flutter analyze
```

**Essential rules** (enabled in analysis_options.yaml):
- avoid_empty_else
- avoid_null_checks_in_equality_operators
- avoid_relative_lib_imports
- avoid_returning_null_for_future
- no_adjacent_strings_in_list
- prefer_const_constructors
- prefer_const_declarations
- prefer_final_fields
- prefer_final_in_for_each
- prefer_final_locals
- use_to_close_create_state

## Documentation Comments

Use doc comments (`///`) for public APIs:

```dart
/// Fetches a user from the repository.
///
/// Returns the [User] with the given [id], or throws [NetworkException]
/// if the request fails.
///
/// Example:
/// ```dart
/// final user = await repository.getUser('123');
/// print(user.name);
/// ```
Future<User> getUser(String id) async {
  // Implementation
}

// ✗ Bad: No documentation
Future<User> getUser(String id) async {
  // Implementation
}
```

## Performance Guidelines

1. **Avoid rebuilds**: Use `const` constructors
2. **Lazy load**: Use GetIt lazy singletons
3. **Cache results**: Use CachedRepositoryMixin
4. **Debounce input**: Use Debouncer for search
5. **Image optimization**: Cache images with flutter_cache_manager
6. **Pagination**: Use BasePaginatedCubit
7. **Memory**: Dispose controllers in dispose()

## Security Practices

1. **Validate input**: Use FormZ validators
2. **Encrypt sensitive data**: Use SecureStorageService
3. **Validate API responses**: Always deserialize with DTO
4. **No secrets in code**: Use Firebase Remote Config
5. **HTTPS only**: Enforce in Dio client configuration
6. **Token rotation**: TokenManager handles refresh
7. **Logout cleanup**: Clear cache and storage on logout

## Git Commit Messages

Use conventional commit format:

```
feat: add user authentication module

- Implement SecureStorageService
- Add TokenManager
- Create AuthenticationInterceptor
- Add SessionManager

Closes #123
```

Types: feat, fix, docs, style, refactor, test, chore

## Code Review Checklist

Before submitting PR:
- [ ] Follows naming conventions
- [ ] Uses appropriate patterns (Repository, UseCase, Cubit)
- [ ] Has error handling
- [ ] Includes tests
- [ ] No unused imports
- [ ] Code is formatted (`dart format`)
- [ ] No analyzer warnings
- [ ] Documentation for public APIs
- [ ] No hardcoded values
- [ ] No sensitive data in code

## Migration Path for Legacy Code

If migrating from old patterns:

1. **Wrap old repository**: Create adapter implementing BaseRepository
2. **Extract use cases**: Gradually move logic to UseCase classes
3. **Update Cubits**: Migrate to BaseCubit
4. **Add caching**: Mix in CachedRepositoryMixin
5. **Improve tests**: Write tests for new layer
