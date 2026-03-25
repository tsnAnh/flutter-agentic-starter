# Quick Start Guide

## 5-Minute Setup

### 1. Clone & Install

```bash
git clone https://github.com/tsnAnh/flutter-bloc-base-source-code.git
cd flutter-bloc-base-source-code
flutter pub get
dart run build_runner build
```

### 2. Run the App

```bash
flutter run -t lib/main_staging.dart
```

## First 30 Minutes: Understand the Structure

### File Layout
```
lib/
├── core/              ← Infrastructure (DO NOT modify lightly)
├── shared/            ← Shared data & widgets
└── features/          ← Your features here
```

### Key Files to Read
1. **Start here**: `lib/core/base/data_state.dart` (5 min)
   - Understand sealed classes and pattern matching
2. **Then**: `lib/features/home/cubit/home_cubit.dart` (5 min)
   - See how to use BaseCubit
3. **Next**: `lib/features/login/login_screen.dart` (5 min)
   - See UI integration
4. **Finally**: `lib/core/di/get_it.dart` (5 min)
   - See dependency injection setup

## Your First Feature (1-2 hours)

### Step 1: Create Feature Structure

```bash
mkdir -p lib/features/my_feature/{cubit,data/repositories,data/models}
```

### Step 2: Define Your Data Model

**File**: `lib/features/my_feature/data/models/my_entity.dart`

```dart
class MyEntity {
  final String id;
  final String name;

  const MyEntity({required this.id, required this.name});

  factory MyEntity.fromJson(Map<String, dynamic> json) {
    return MyEntity(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
```

### Step 3: Create Repository

**File**: `lib/features/my_feature/data/repositories/my_repository.dart`

```dart
// Abstract
abstract class MyRepository {
  Future<List<MyEntity>> getItems();
  Future<void> createItem(MyEntity item);
}

// Implementation
class MyRepositoryImpl extends BaseRepository implements MyRepository {
  final DioClient dio;

  MyRepositoryImpl(this.dio);

  @override
  Future<List<MyEntity>> getItems() async {
    final response = await dio.get('/items');
    return (response.data as List)
        .map((json) => MyEntity.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> createItem(MyEntity item) async {
    await dio.post('/items', data: item.toJson());
  }
}
```

### Step 4: Create Use Case

**File**: `lib/features/my_feature/data/repositories/get_items_use_case.dart`

```dart
class GetItemsUseCase extends UseCase<void, List<MyEntity>> {
  @override
  Future<List<MyEntity>> call([void input]) async {
    return getIt<MyRepository>().getItems();
  }
}
```

### Step 5: Create Cubit

**File**: `lib/features/my_feature/cubit/my_cubit.dart`

```dart
class MyCubit extends BaseCubit<List<MyEntity>> {
  final GetItemsUseCase getItems;

  MyCubit({required this.getItems}) : super();

  @override
  Future<List<MyEntity>> fetch() => getItems();
}
```

### Step 6: Create Screen

**File**: `lib/features/my_feature/my_screen.dart`

```dart
class MyScreen extends StatefulWidget {
  const MyScreen({Key? key}) : super(key: key);

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MyCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Feature')),
      body: BlocBuilder<MyCubit, DataState<List<MyEntity>>>(
        builder: (context, state) => switch (state) {
          DataStateInitial() => const SizedBox.shrink(),
          DataStateLoading() => const Center(child: CircularProgressIndicator()),
          DataStateLoaded(:final data) => ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(data[index].name),
              subtitle: Text(data[index].id),
            ),
          ),
          DataStateError(:final message) => ErrorWidget(message: message),
        },
      ),
    );
  }
}
```

### Step 7: Register in DI

**File**: `lib/core/di/get_it.dart`

Add to `setupServiceLocator()`:

```dart
// Register repository
getIt.registerLazySingleton<MyRepository>(
  () => MyRepositoryImpl(getIt<DioClient>()),
);

// Register use case
getIt.registerLazySingleton<GetItemsUseCase>(
  () => GetItemsUseCase(),
);

// Register cubit
getIt.registerFactory<MyCubit>(
  () => MyCubit(getItems: getIt<GetItemsUseCase>()),
);
```

### Step 8: Add Route (if using GoRouter)

**File**: `lib/core/router/router.dart`

```dart
GoRoute(
  path: '/my-feature',
  builder: (context, state) => BlocProvider(
    create: (context) => getIt<MyCubit>(),
    child: const MyScreen(),
  ),
),
```

### Step 9: Test Your Feature

Navigate to the feature or run:

```bash
flutter test
```

## Common Patterns

### Pattern 1: Fetch Data on Screen Load

```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen opens
    context.read<MyCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyCubit, DataState<Data>>(
      builder: (context, state) => switch (state) {
        DataStateLoaded(:final data) => MyContent(data: data),
        DataStateLoading() => const LoadingWidget(),
        DataStateError(:final message) => ErrorWidget(message: message),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
```

### Pattern 2: Handle Mutation (Create/Update)

```dart
void _onSubmit() async {
  emit(const DataStateLoading());
  try {
    await repository.createItem(item);
    emit(DataStateLoaded(updatedData));
  } on Object catch (e, st) {
    emit(DataStateError(e.toString(), st));
  }
}
```

### Pattern 3: Pagination

```dart
class MyPaginatedCubit extends BasePaginatedCubit<MyEntity> {
  final MyRepository repository;

  MyPaginatedCubit({required this.repository});

  @override
  Future<List<MyEntity>> fetch(int page) async {
    return repository.getItems(page: page);
  }
}
```

### Pattern 4: Cache Data

```dart
class MyCubit extends BaseCubit<Data> {
  @override
  Future<Data> fetch() async {
    const cacheKey = 'my_data';

    // Check cache first
    final cached = getIt<CacheManager>().get<Data>(cacheKey);
    if (cached != null) return cached;

    // Fetch and cache
    final data = await repository.getData();
    getIt<CacheManager>().set(cacheKey, data);

    return data;
  }
}
```

### Pattern 5: Offline Support

```dart
Future<void> saveItem(Item item) async {
  try {
    await repository.save(item);
    emit(DataStateLoaded(item));
  } on OfflineException {
    // Queue for later
    await getIt<OfflineQueueService>().queue(
      method: 'POST',
      path: '/items',
      data: item.toJson(),
    );
    emit(DataStateLoaded(item)); // Optimistic update
  }
}
```

## Debugging Tips

### 1. Enable Bloc Observer Logging

Already enabled in `main.dart`. Look at console for events/states.

### 2. Inspect DioClient Requests

Enable logging in `core/network/dio.dart`:

```dart
if (kDebugMode) {
  _dio.interceptors.add(LoggingInterceptor());
}
```

### 3. Check Cache

```dart
final cacheManager = getIt<CacheManager>();
final allCached = cacheManager.getAll(); // See what's cached
```

### 4. Check Connectivity

```dart
final isOnline = getIt<ConnectivityService>().isOnline;
print('Online: $isOnline');
```

### 5. View Analytics Events

Enable Firebase console or check PostHog dashboard.

## Common Issues & Solutions

### Issue: "Service not found in GetIt"

**Solution**: Add registration to `get_it.dart`:

```dart
getIt.registerSingleton<MyService>(MyService());
```

### Issue: "State not updating"

**Solution**: Ensure you're emitting new state:

```dart
// ✓ Correct
emit(DataStateLoaded(newData));

// ✗ Wrong
state = DataStateLoaded(newData); // Doesn't emit
```

### Issue: "Network request hangs"

**Solution**: Check timeout settings:

```dart
// In DioClient
const baseOptions = BaseOptions(
  connectTimeout: Duration(seconds: 10),
  receiveTimeout: Duration(seconds: 10),
);
```

### Issue: "Token not being refreshed"

**Solution**: Ensure AuthenticationInterceptor is registered:

```dart
_dio.interceptors.add(AuthenticationInterceptor());
```

### Issue: "Data not cached"

**Solution**: Use CachedRepositoryMixin:

```dart
class MyRepository with CachedRepositoryMixin {
  // Repository implementation
}
```

## Next Steps

1. **Read Documentation**
   - [ ] System Architecture (`docs/system-architecture.md`)
   - [ ] Code Standards (`docs/code-standards.md`)
   - [ ] Module Guides (`docs/module-guides.md`)

2. **Explore Examples**
   - [ ] `lib/features/login/` - Authentication
   - [ ] `lib/features/home/` - Data fetching

3. **Implement Your Features**
   - [ ] Follow the pattern above
   - [ ] Write tests as you go
   - [ ] Use code review checklist

4. **Optimize**
   - [ ] Add caching where needed
   - [ ] Profile performance
   - [ ] Add analytics events

## Resources

| Resource | Purpose | Link |
|----------|---------|------|
| Repository | Source code | [GitHub](https://github.com/tsnAnh/flutter-bloc-base-source-code) |
| Flutter Docs | Flutter reference | [flutter.dev](https://flutter.dev) |
| BLoC Docs | State management | [bloclibrary.dev](https://bloclibrary.dev) |
| Dart Docs | Language reference | [dart.dev](https://dart.dev) |

## Support

- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions
- **Example**: [bit](https://github.com/tsnAnh/bit) project

---

**Estimated Time**: 1-2 hours to create and integrate your first feature.

