---
type: Project Memory
title: Coding Patterns
description: Durable coding and architecture patterns agents should preserve in this Flutter starter.
tags: [okf-memory, flutter-agentic-starter, coding-patterns]
timestamp: 2026-06-21T11:34:45+07:00
memory_category: coding-patterns
merged_through: 2026-06-18
---

# Current Patterns

* Keep infrastructure and reusable app code in `lib/core/` and `lib/shared/`.
* Put feature code under `lib/features/<feature>/`.
* Use existing Clean Architecture with presentation, domain, and data layers.
* Use BLoC/Cubit for presentation state.
* Use `DataState<T>` for async state and exhaustive state handling.
* Use repositories for data access and use cases for business logic.
* Use GetIt + Injectable for dependency injection.
* Edit source files before regenerating build_runner outputs; never manually edit generated files.
* Prefer maintained pub.dev packages before custom reusable Flutter/Dart utilities, widgets, integrations, or helpers.
* OKF memory uses plain markdown concept files with YAML frontmatter and reserved `index.md` and `log.md` files.
