# Flutter Agentic Starter documentation

Flutter Agentic Starter combines Clean Architecture with Signals view models.

## Guides

- [Quick start](quick-start-guide.md)
- [System architecture](system-architecture.md)
- [Code standards](code-standards.md)
- [Module guides](module-guides.md)
- [Codebase summary](codebase-summary.md)
- [Product requirements](project-overview-pdr.md)
- [Development roadmap](development-roadmap.md)

## State model

- Feature state belongs to an injectable view model.
- Mutable signals stay private and are exposed as `ReadonlySignal`.
- Async work uses `AsyncState<T>`.
- Derived state uses `computed`.
- Related writes use `batch` only when they must publish atomically.
- Screens use `SignalWidget` or narrow `SignalBuilder` boundaries.
- Effects and connections are exceptional and explicitly disposed.
- One-shot UI actions stay at the widget boundary.

Included skills: `flutter-agentic-starter`, `caveman`, and `frontend-design`.
