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

## Type Safety & Primitive Obsession

- Use platform/library types first: `Duration`, `Instant`, `LocalDate`, URI/Ktor URL types, and platform UI enums.
- Use `enum class` for finite choices: status, mode, policy, sort, tab, validation error.
- Use sealed `interface`/`class` for exhaustive states, results, and events, especially when cases carry payloads.
- Use `@JvmInline value class` for high-risk primitives: money, units, validated input, and repeated IDs with behavior.
- Use Arrow `Either`, `Option`, and existing aliases for errors/absence instead of raw nullable or stringly wrappers.
- Never persist or API-map enum `ordinal`; avoid raw `name` unless it is the explicit stable wire contract.
- Parse raw strings/ints at API, config, route, storage, and serialization boundaries; keep typed values inside shared/domain code.
- Add unknown/fallback handling for backend-controlled enum values.
- Keep open text, localized/generated strings, raw JSON, and behaviorless simple IDs primitive.

## Agent Review Checklist

- Are closed sets typed instead of raw `String`/`Int`?
- Are multi-mode booleans replaced with enum or sealed state?
- Are wire values explicit and stable?
- Are external values parsed at boundaries with fallback?
- Are open text, localized/generated strings, raw JSON, and behaviorless simple IDs left primitive?
