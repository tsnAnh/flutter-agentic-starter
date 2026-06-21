---
type: Project Memory
title: Coding Patterns
description: Durable coding and architecture patterns agents should preserve in this KMP starter.
tags: [okf-memory, creative-note, coding-patterns]
timestamp: 2026-06-21T11:55:21+07:00
memory_category: coding-patterns
merged_through: 2026-06-18
---

# Current Patterns

* Keep shared business logic, repositories, use cases, and shared ViewModels in `shared`.
* Keep Android UI in `androidApp` with Jetpack Compose.
* Keep iOS UI in `iosApp` with SwiftUI.
* Put feature code under `shared/src/commonMain/.../features/<feature>/`.
* Put reusable shared infrastructure under `shared/src/commonMain/.../core/`.
* Wire dependencies through Koin modules in `di`.
* Use feature layers: `domain/models`, `domain/repositories`, `domain/usecases`, `data/datasources`, `data/repositories`, and `presentation`.
* Keep domain models plain Kotlin. Keep DTOs, Room entities, DAOs, and mappers in data layers.
* Use Arrow `Either`, `Option`, `AppResult`, `AsyncResult`, and `OptionalResult` at shared boundaries.
* Prefer maintained KMP packages before custom reusable framework code.
* OKF memory uses plain markdown concept files with YAML frontmatter and reserved `index.md` and `log.md` files.
