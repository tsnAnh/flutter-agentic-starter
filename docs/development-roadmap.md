# Development roadmap

## Complete

- [x] Breaking cutover to Signals 7 view models
- [x] Private mutable signals with read-only public state
- [x] Signal-native session, connectivity, offline queue, and permissions
- [x] Home `data/domain/presentation` reference feature
- [x] Typed async state and localized retry UI
- [x] GetIt/Injectable composition and GoRouter route-boundary injection
- [x] New Dart/native identity and setup-wizard expectations
- [x] Focused view-model, service, widget, and setup tests

## Next

- [ ] Replace memory-only token storage with platform secure storage
- [ ] Add a real authentication feature and session-aware redirects
- [ ] Add feature examples only when product requirements need them
- [ ] Add integration tests against an owned staging API
- [ ] Add CI release builds and signed deployment workflows

## Dependency note

`signals_lint` runs as an analyzer plugin. Its analyzer requirement currently
needs the compatible Injectable 3 and Freezed 4 prerelease generator line; keep
those three packages upgraded together until Freezed 4 is stable.
