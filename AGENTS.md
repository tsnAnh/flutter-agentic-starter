# AGENTS.md

This file provides guidance to OpenCode when working with code in this repository.

## Project Overview

**Name:** flutter-agentic-starter
**Type:** Flutter/Dart
**Description:** Production-ready Flutter Signals starter template optimized for AI coding agents. Clean architecture, core modules, multi-flavor support. Built for vibe coding with Claude Code, Cursor, and other AI assistants.

## Role & Responsibilities

Your role is to analyze user requirements, delegate tasks to appropriate sub-agents, and ensure cohesive delivery of features that meet specifications and architectural standards.

## Workflows

- Primary workflow: `./.claude/rules/primary-workflow.md`
- Development rules: `./.claude/rules/development-rules.md`
- Orchestration protocols: `./.claude/rules/orchestration-protocol.md`
- Documentation management: `./.claude/rules/documentation-management.md`
- And other workflows: `./.claude/rules/*`

**IMPORTANT:** Analyze the skills catalog and activate the skills that are needed for the task during the process.
**IMPORTANT:** You must follow strictly the development rules in `./.claude/rules/development-rules.md` file.
**IMPORTANT:** Before you plan or proceed any implementation, always read the `./README.md` file first to get context.
**IMPORTANT:** Sacrifice grammar for the sake of concision when writing reports.
**IMPORTANT:** In reports, list any unresolved questions at the end, if any.

## Development Principles

- **YAGNI**: You Aren't Gonna Need It - avoid over-engineering
- **KISS**: Keep It Simple, Stupid - prefer simple solutions
- **DRY**: Don't Repeat Yourself - eliminate code duplication
- **Karpathy Guidelines**: Think before coding, keep changes simple, edit surgically, and define verifiable success criteria.

## Coding Agent Rules

- Read `README.md` and relevant docs before implementation.
- State assumptions when requirements are ambiguous; ask before risky guesses.
- **Hard rule:** Minimal focused edits only. Touch only files and lines required for requested behavior.
- **Hard rule:** Do not rewrite, reformat, reorder, regenerate, or clean up unrelated code unless required.
- **Hard rule:** Never manually edit build_runner generated files, including `*.g.dart`, `*.freezed.dart`, `*.config.dart`, or files marked `GENERATED CODE - DO NOT MODIFY BY HAND`.
- **Hard rule:** Avoid primitive obsession. Prefer existing SDK/package types, enums/enhanced enums, sealed classes, or small value objects over raw `String`, raw `int`, raw `bool`, and magic constants for finite or high-risk domain concepts. Parse wire primitives at boundaries; keep raw primitives only for open user text, raw JSON/generated/localized output, and simple IDs/keys without behavior.
- **Hard rule:** Prefer maintained pub.dev packages before implementing reusable Flutter/Dart utilities, widgets, integrations, or helpers yourself.
- **Hard rule:** For Flutter source icons/images, find suitable existing internet assets instead of creating them yourself. Prefer SVG for icons/simple vectors, PNG/JPG for raster/photo use cases, and record source/license when adding assets.
- Keep ephemeral widget-only UI state local with `StatefulWidget`/`setState`; use injectable feature view models with private `Signal` fields and public `ReadonlySignal` views for shared, persisted, business-critical, or asynchronous state.
- Use `SignalWidget` for signal-driven screens and focused `SignalBuilder` boundaries when only a subtree should rebuild. Use `AsyncState<T>` for loading/data/error, `computed` for derived state, and `batch` when multiple writes must publish atomically.
- Keep navigation, dialogs, and snackbars at the widget boundary. Explicitly dispose every `effect`, signal subscription, stream connection, and lifecycle observer owned by a long-lived object. Do not use `.watch(context)` or `SignalsMixin`.
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
- Document any pub.dev package-first exception with reason.
- Keep repo-owned source code files under 300 lines when practical; split focused concerns when it improves readability.
- Respect dirty worktrees. Never revert user changes unless explicitly asked.
- Verify changes with `flutter analyze` and `flutter test` when code changes.
- For generated code changes, edit source files only, then run `dart run build_runner build --delete-conflicting-outputs`.
- Treat `.env`, API keys, tokens, and platform secrets as confidential.

## Documentation

Keep all important docs in `./docs` folder:

```
./docs
├── project-overview-pdr.md
├── code-standards.md
├── codebase-summary.md
├── design-guidelines.md
└── system-architecture.md
```

Root workflow files live in `./.claude/rules/`. Keep `AGENTS.md`,
`CLAUDE.md`, `.cursor/rules/flutter.mdc`, and docs aligned when structure
changes.

## External Files

Reference external instruction files in `opencode.json`:

```json
{
  "instructions": ["docs/*.md", ".opencode/agents/*.md"]
}
```

## Project Skills

Native project skills are provided for Claude Code, Codex, and OpenCode:

- Claude Code: `.claude/skills/`
- Codex: `.agents/skills/`
- OpenCode: `.opencode/skills/`

Available skills:

Use `flutter-agentic-starter` only when implementing Flutter application code
under `lib/`, Flutter tests, or platform integration required by that code. Do
not activate it for documentation, setup tooling, repository automation, or
other non-app maintenance.

- `flutter-agentic-starter`: Flutter, Signals/ViewModel, Clean Architecture, DI, routing, models, tests, and design system guidance.
- `caveman`: terse technical communication mode for concise reports.
- `frontend-design`: polished UI/frontend design guidance for user-facing surfaces.

---
