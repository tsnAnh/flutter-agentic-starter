# Module Guides

- Network: create `HttpClient` through `KtorHttpClientFactory`; auth token injection comes from `TokenManager`.
- Feature layout: use `domain/models`, `domain/repositories`, `domain/usecases`, `data/datasources`, `data/repositories`, and `presentation`.
- State: expose `DataState<T>` for loading/loaded/error and simple Swift-friendly flows when needed.
- Cache: use `CacheManager` for in-memory TTL cache; replace with SQLDelight for persistent app data.
- Auth: use `TokenManager` and `SessionManager`; swap `SecureTokenStore` with platform secure storage for production.
- Analytics/Firebase: use shared facades; wire real providers in app modules when credentials exist.
- Permissions: keep shared permission contract, use platform implementations for app-specific permission prompts.
