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

- Keep edits minimal and focused. Do not rewrite, reformat, reorder, or clean unrelated code.
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
- Use GetIt + Injectable for dependencies. Run code generation after DI/model changes.

## UI

- Reuse `core/design_system` tokens and existing theme extensions.
- Keep app screens work-focused, accessible, responsive, and consistent with current Material 3 design.
- Extract widgets only when it reduces real duplication or keeps files below practical size.
- For polished web-style surfaces, use the `frontend-design` skill before implementing UI.

## Verification

- Run `flutter analyze` after Dart code changes.
- Run `flutter test` after behavior or test changes.
- Run `dart run build_runner build --delete-conflicting-outputs` after Injectable, Freezed, or JSON model changes.
- Report changed behavior, verification results, and unresolved questions.
