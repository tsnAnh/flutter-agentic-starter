# Module Guides

- Network: create `HttpClient` through `KtorHttpClientFactory`; auth token injection comes from `TokenManager`.
- Feature layout: use `domain/models`, `domain/repositories`, `domain/usecases`, `data/datasources`, `data/repositories`, and `presentation`.
- Data boundaries: keep wire DTOs and Room entities in `data`; map them to plain domain models before presentation.
- State: expose Arrow typed errors/options for primary state and simple Swift-friendly derived flows when needed.
- Storage: use Room KMP for persistent feature data; commit generated schemas under `shared/schemas/`.
- Cache: use `CacheManager` only for short-lived in-memory TTL values.
- Auth: use `TokenManager` and `SessionManager`; swap `SecureTokenStore` with platform secure storage for production.
- Analytics/Firebase: use shared facades; wire real providers in app modules when credentials exist.
- Permissions: keep shared permission contract, use platform implementations for app-specific permission prompts.
