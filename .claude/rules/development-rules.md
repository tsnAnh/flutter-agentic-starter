# Development Rules

## Principles

- YAGNI, KISS, DRY.
- Karpathy Guidelines: think before coding, keep simple, edit surgically, verify concrete goals.

## Non-Negotiable Rules

- Minimal focused edits are mandatory: touch only files and lines required for the requested behavior.
- Do not rewrite, reformat, reorder, regenerate, or clean up unrelated code unless required by the task.
- Do not create enhanced replacement files; update existing files directly.
- Never manually edit build_runner generated files, including `*.g.dart`, `*.freezed.dart`, `*.config.dart`, or files marked `GENERATED CODE - DO NOT MODIFY BY HAND`.
- Avoid primitive obsession: prefer existing SDK/package types, enums/enhanced enums, sealed classes, or small value objects over raw `String`, raw `int`, raw `bool`, and magic constants for finite or high-risk domain concepts. Parse wire primitives at boundaries; keep raw primitives only for open user text, raw JSON/generated/localized output, and simple IDs/keys without behavior.
- Package-first is mandatory for Flutter/Dart: check and prefer maintained pub.dev packages before implementing reusable utilities, widgets, integrations, or helpers yourself.
- Custom Flutter/Dart implementation is allowed only when no suitable package exists, or when packages fail security, privacy, license, platform, size, performance, or architecture requirements.
- Document any package-first exception in the plan, report, PR, or code review summary.
- For Flutter source icons/images, find suitable existing internet assets instead of creating them yourself. Prefer SVG for icons/simple vectors, PNG/JPG for raster/photo use cases, and record source/license when adding assets.
- Keep ephemeral widget-only UI state local with `StatefulWidget`/`setState`; use Cubit/BLoC for shared, persisted, business-critical, or complex state.
- Use `BlocSelector`, `context.select`, `buildWhen`, and `listenWhen` to limit rebuilds/listener calls. Use `BlocListener` or a `BlocConsumer` listener for one-shot effects like navigation, dialogs, and snackbars.
- Use `SafeArea`; honor text scaling and accessibility-aware `MediaQuery`.
- Use `LayoutBuilder` for parent constraints and `MediaQuery.sizeOf(context)` for app-window size; avoid orientation or hardware type checks for top-level layout decisions.
- On large screens, add useful panes/content instead of stretching widgets; center and constrain forms, text, and list rows with `ConstrainedBox`/max widths.
- Use lazy builders for long lists/grids. Use `GridView.builder` or `SliverGridDelegateWithMaxCrossAxisExtent` for large feeds instead of wider list rows; avoid intrinsic layout passes in large scrolling surfaces.
- Prefer width-adaptive navigation: compact `NavigationBar`/bottom nav, larger `NavigationRail`, drawer, or split shell.
- Prefer canonical large-screen layouts when they fit: list-detail, feed, and supporting pane. Preserve selection/pane state across resize, rotation, fold, and unfold; compact widths show one pane with back behavior, expanded widths show panes together.
- For foldables, do not lock orientation; use `MediaQuery.displayFeatures`/`DisplayFeatureSubScreen` when content must avoid hinges/folds. Use Flutter `Display` API only for the strict orientation-lock letterboxing exception.
- Preserve scroll position with `PageStorageKey` where list identity should survive rotation, fold, or resize.
- Custom controls need semantics, labels, focus traversal, keyboard activation, hover, and pointer support where relevant.
- Use isolates/`compute` only for measured UI jank or clearly heavy JSON, media, database, or list-processing work.
- Add `restorationScopeId`/`restorationId` for `MaterialApp.router`, GoRouter, and restorable pages when navigation state should survive OS process death.
- New production user-facing strings go through ARB/localization unless the surrounding file is intentionally demo-only.
- Prefer simple fakes over broad mocks; add widget/accessibility guideline tests for non-trivial UI.
- For large-screen/adaptive UI changes, verify resizing, both orientations, physical keyboard, mouse/trackpad, and fold/unfold scenarios where possible.

## Editing

- Use smallest correct patch.
- Preserve existing structure, comments, naming, and formatting unless change requires it.
- Do not revert user changes in dirty worktrees.
- Do not commit secrets, `.env`, API keys, or credentials.
- Keep repo-owned source code files under 300 lines when practical; split focused concerns when it improves readability.
- Do not split generated files, docs, configs, assets, lockfiles, or build artifacts for line count alone.

## Verification

- Run `flutter analyze` after code changes.
- Run `flutter test` after behavior/test changes.
- For injectable, Freezed, or JSON model changes, edit source files only, then run `dart run build_runner build --delete-conflicting-outputs`.
