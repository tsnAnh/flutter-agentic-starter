# Code Standards

- Kotlin packages: lowercase reverse-domain.
- Kotlin classes: `PascalCase`; functions/properties: `camelCase`.
- Keep shared business logic in `shared`.
- Keep Android-only UI in `androidApp`; keep iOS-only UI in `iosApp`.
- Use Arrow `Either` and `Option` aliases for typed async presentation state.
- Use `domain/repositories` for contracts and `data/repositories` for implementations.
- Use `data/datasources` for APIs, storage, and external data access.
- Keep serialization and Room annotations out of domain models.
- Use `domain/usecases` for business logic and `domain/models` for feature models.
- Use Koin for DI.
- Prefer Ktor/Koin/kotlinx libraries and maintained KMP packages over custom framework code.
- Keep source files under 300 lines when practical.
