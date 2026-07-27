# Module guides

## Home

Home is the reference feature:

```text
CityApi -> CityRepositoryImpl -> GetCities -> HomeViewModel -> HomeScreen
```

`HomeViewModel.cities` starts as `null` so the screen can show an explicit
"Load cities" action. `loadCities()` then publishes `AsyncLoading`,
`AsyncData`, or `AsyncError`. The screen localizes errors and exposes retry.

## Session

`SessionManager.active` is the source of truth for the current session. A new
process starts signed out. `startSession`, explicit logout, and inactivity
expiry update the signal synchronously; the event stream remains for one-shot
expiry/logout coordination.

## Connectivity and offline writes

`ConnectivityService.online` reflects network-interface availability and
`offline` is computed from it. This is not an internet-reachability guarantee.

`OfflineQueueService` stores eligible failed writes in Hive. It subscribes to
the online signal, replays FIFO on reconnect with a fresh token, exposes
`pendingCount`, and disposes its subscription and box.

## Permissions

`PermissionViewModel.statuses` maps app permission enums to current status.
The view model checks, requests, and rechecks known permissions when the app
resumes. Consumers that create it must call `dispose` so its lifecycle observer
is removed.

## Request cancellation

Use `RequestCancellationMixin` only on a concrete view model that issues
cancellable Dio requests. Call its `dispose` from the owning widget or scope.
Do not add a base view-model hierarchy.

## Adding a signal-backed service

1. Keep its mutable signal private.
2. Expose a `ReadonlySignal`.
3. Derive values with `computed`.
4. Store cleanup returned by `effect` or `subscribe`.
5. Dispose every owned connection and signal with a finite lifetime.
6. Add a focused test for transitions and cleanup.
