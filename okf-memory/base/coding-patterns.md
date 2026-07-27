---
type: Project Memory
title: Coding Patterns
description: Durable coding and architecture patterns agents should preserve in this Flutter starter.
tags: [okf-memory, flutter-agentic-starter, coding-patterns]
timestamp: 2026-07-27T00:00:00+07:00
memory_category: coding-patterns
merged_through: 2026-07-27
---

# Current Patterns

* Keep infrastructure and reusable app code in `lib/core/` and `lib/shared/`.
* Put feature code under `lib/features/<feature>/`.
* Use existing Clean Architecture with presentation, domain, and data layers.
* Use injectable feature view models with private mutable `Signal` fields and public `ReadonlySignal` views for presentation state.
* Use `AsyncState<T>` for async state and exhaustive state handling.
* Use `SignalWidget` or focused `SignalBuilder` boundaries, `computed` for derived state, and `batch` only for atomic multi-signal writes.
* Keep one-shot UI effects at the widget boundary and explicitly dispose owned effects, signal subscriptions, stream connections, timers, and lifecycle observers.
* Do not use deprecated `.watch(context)` or `SignalsMixin` APIs.
* Use repositories for data access and use cases for business logic.
* Use GetIt + Injectable for dependency injection.
* Edit source files before regenerating build_runner outputs; never manually edit generated files.
* Prefer maintained pub.dev packages before custom reusable Flutter/Dart utilities, widgets, integrations, or helpers.
* Future Flutter/Dart code should avoid primitive obsession: prefer existing SDK/package types, enums/enhanced enums, sealed classes, or small value objects over raw primitives for finite or high-risk domain concepts.
* Keep ephemeral widget-only state local and limit reactive rebuilds to the smallest useful widget subtree.
* Flutter UI should use `SafeArea`, size-based layouts, semantics, focus/keyboard/pointer affordances for custom controls, lazy builders for long lists/grids, state restoration IDs when needed, and ARB localization for production strings.
* Large-screen UI should use constraint-based layouts, adaptive navigation, useful supporting panes, foldable display-feature handling, and preserved list identity where resizing should retain state.
* OKF memory uses plain markdown concept files with YAML frontmatter and reserved `index.md` and `log.md` files.
