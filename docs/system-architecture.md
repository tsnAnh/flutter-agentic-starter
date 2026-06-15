# System Architecture

```text
Android Compose UI        iOS SwiftUI UI
        |                       |
        +------ shared ViewModels
                        |
                  Domain/use cases
                        |
                  Repositories
                        |
        Core services: Ktor, cache, auth, analytics, permissions, logger
```

Shared code uses Clean Architecture:

- `core`: reusable infrastructure and platform-safe abstractions.
- `features/<feature>/domain/models`: domain models.
- `features/<feature>/domain/repositories`: repository contracts.
- `features/<feature>/domain/usecases`: business use cases.
- `features/<feature>/data/datasources`: APIs, local storage, and platform-safe data sources.
- `features/<feature>/data/repositories`: repository implementations.
- `features/<feature>/presentation`: KMP ObservableViewModel classes.
- `di`: Koin modules.
