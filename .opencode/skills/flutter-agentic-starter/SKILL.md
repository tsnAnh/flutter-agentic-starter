---
name: flutter-agentic-starter
description: >
  Project-specific Flutter/Dart implementation guidance for flutter-agentic-starter.
  Invoke this app-named skill first before working in this project.
  Use when working on Flutter code, BLoC/Cubit state, clean architecture features,
  DI, routing, models, tests, design system UI, or project setup in this repository.
---

# Flutter Agentic Starter

Follow repo docs first: `README.md`, `AGENTS.md` or `CLAUDE.md`, and relevant files in `docs/`.

## Core Rules

- Use `.agents/skills/manage-okf-memory` at start/end to maintain `okf-memory/`.
- Keep edits minimal and focused. Do not rewrite, reformat, reorder, or clean unrelated code.
- Avoid primitive obsession. Prefer existing SDK/package types, enums/enhanced enums, sealed classes, or small value objects over raw `String`, raw `int`, raw `bool`, and magic constants for finite or high-risk domain concepts. Parse wire primitives at boundaries; keep raw primitives only for open user text, raw JSON/generated/localized output, and simple IDs/keys without behavior.
- Prefer maintained pub.dev packages before custom reusable Flutter/Dart utilities, widgets, integrations, or helpers.
- Document package-first exceptions in plan, report, PR, or review summary.
- For Flutter source icons/images, find suitable existing internet assets instead of creating them yourself. Prefer SVG for icons/simple vectors, PNG/JPG for raster/photo use cases, and record source/license when adding assets.
- Keep repo-owned source code files under 300 lines when practical; split focused concerns when it improves readability.
- Preserve dirty worktrees. Never revert user changes unless explicitly asked.
- Treat `.env`, API keys, tokens, and platform secrets as confidential.

## Architecture

- Use existing Clean Architecture + BLoC/Cubit patterns.
- Place infrastructure in `lib/core/`, shared app code in `lib/shared/`, and feature code in `lib/features/<feature>/`.
- Use `DataState<T>` for async state and exhaustive state handling.
- Use repositories for data access, use cases for business logic, and BLoC/Cubit for presentation state.
- Keep ephemeral widget-only UI state local with `StatefulWidget`/`setState`; use Cubit/BLoC for shared, persisted, business-critical, or complex state.
- Use `BlocSelector`, `context.select`, `buildWhen`, and `listenWhen` to limit rebuilds/listener calls. Put one-shot effects in `BlocListener` or a `BlocConsumer` listener.
- Use GetIt + Injectable for dependencies. Run code generation after DI/model changes.
- Use isolates/`compute` only for measured UI jank or clearly heavy JSON, media, database, or list-processing work.
- Add `restorationScopeId`/`restorationId` for `MaterialApp.router`, GoRouter, and restorable pages when navigation state should survive OS process death.

## UI

- Reuse `core/design_system` tokens and existing theme extensions.
- Keep app screens work-focused, accessible, responsive, and consistent with current Material 3 design.
- Use `SafeArea`; honor text scaling and accessibility-aware `MediaQuery`.
- Use `LayoutBuilder` for parent constraints and `MediaQuery.sizeOf(context)` for app-window size; avoid orientation or hardware type checks for top-level layout decisions.
- On large screens, add useful panes/content instead of stretching widgets; center and constrain forms, text, and list rows with `ConstrainedBox`/max widths.
- Use lazy builders for long lists/grids. Use `GridView.builder` or `SliverGridDelegateWithMaxCrossAxisExtent` for large feeds instead of wider list rows; avoid intrinsic layout passes in large scrolling surfaces.
- Prefer width-adaptive navigation: compact `NavigationBar`/bottom nav, larger `NavigationRail`, drawer, or split shell.
- Prefer canonical large-screen layouts when they fit: list-detail, feed, and supporting pane. Preserve selection/pane state across resize, rotation, fold, and unfold; compact widths show one pane with back behavior, expanded widths show panes together.
- For foldables, do not lock orientation; use `MediaQuery.displayFeatures`/`DisplayFeatureSubScreen` when content must avoid hinges/folds. Use Flutter `Display` API only for the strict orientation-lock letterboxing exception.
- Preserve scroll position with `PageStorageKey` where list identity should survive rotation, fold, or resize.
- Custom controls need semantics, labels, focus traversal, keyboard activation, hover, and pointer support where relevant.
- Route new production user-facing strings through ARB/localization unless the surrounding file is intentionally demo-only.
- Extract widgets only when it reduces real duplication or keeps files below practical size.
- For polished web-style surfaces, use the `frontend-design` skill before implementing UI.

## Verification

- Run `flutter analyze` after Dart code changes.
- Run `flutter test` after behavior or test changes.
- Prefer simple fakes over broad mocks; test Cubit/BLoC/use-case logic separately from widgets.
- Add widget/accessibility guideline tests for non-trivial UI, especially custom controls and new flows.
- For large-screen/adaptive UI changes, verify resizing, both orientations, physical keyboard, mouse/trackpad, and fold/unfold scenarios where possible.
- Run `dart run build_runner build --delete-conflicting-outputs` after Injectable, Freezed, or JSON model changes.
- Report changed behavior, verification results, and unresolved questions.
