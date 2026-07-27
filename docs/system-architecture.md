# System architecture

## Feature flow

```mermaid
flowchart LR
    UI["Screen<br/>SignalWidget / SignalBuilder"] --> VM["Injectable ViewModel"]
    VM --> UC["Use case"]
    UC --> RC["Domain repository contract"]
    RI["Data repository implementation"] -. implements .-> RC
    RI --> DS["Dio / Hive data source"]
    VM --> RS["ReadonlySignal<br/>AsyncState&lt;T&gt;"]
    RS --> UI
```

Dependencies point toward domain code. The data layer implements domain
contracts; presentation never depends directly on Dio or Hive.

## State ownership

```mermaid
flowchart TD
    VM["Concrete owner"] --> MS["private Signal&lt;T&gt;"]
    MS --> RO["public ReadonlySignal&lt;T&gt;"]
    RO --> UI["Signal-aware widget"]
    MS --> CO["computed derived state"]
    VM --> CL["dispose owned effects,<br/>subscriptions, timers, observers"]
```

- Widget-only interaction state stays local.
- Feature state lives in a route-scoped view model.
- Cross-feature state lives in a focused lazy-singleton service.
- Derived state uses `computed`, not duplicated mutable values.
- `batch` groups only writes that must be observed atomically.

## Async request sequence

```mermaid
sequenceDiagram
    participant U as User
    participant S as HomeScreen
    participant V as HomeViewModel
    participant C as GetCities
    participant R as CityRepository
    U->>S: Tap Load cities
    S->>V: loadCities()
    V-->>S: AsyncLoading
    V->>C: call()
    C->>R: getCities()
    alt success
        R-->>V: Right(cities)
        V-->>S: AsyncData(cities)
    else failure
        R-->>V: Left(NetworkError)
        V-->>S: AsyncError(error)
        S-->>U: Localized generic error + Retry
    end
```

## App composition

`initializeFlutterApp` initializes Flutter bindings, Firebase, Hive, Injectable,
cache, connectivity, offline queue, error reporting, and analytics before
mounting `App`. Signals uses its built-in debug tooling; the app does not add a
parallel state observer.

GoRouter owns navigation. A route resolves its feature view model from GetIt
and passes it into the screen constructor. This makes dependencies explicit and
keeps providers out of the widget tree.

## Long-lived reactive services

- `SessionManager.active`: volatile session state; starts false.
- `ConnectivityService.online`: interface availability.
- `ConnectivityService.offline`: computed inverse.
- `OfflineQueueService.pendingCount`: Hive queue length.
- `PermissionViewModel.statuses`: permission state with resume rechecks.

Any service that creates a connection stores its cleanup and releases it from
`dispose`.
