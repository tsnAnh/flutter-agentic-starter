---
type: Project Memory
title: Major Changes
description: Significant repository changes agents should know before editing.
tags: [okf-memory, flutter-agentic-starter, major-changes]
timestamp: 2026-07-27T00:00:00+07:00
memory_category: major-changes
merged_through: 2026-07-27
---

# Current Major Changes

* The project is a production-ready Flutter Signals starter template with Clean Architecture, GetIt/Injectable DI, GoRouter, Dio, Hive, Firebase/PostHog facades, Material 3, and agent-ready rules.
* `lib/features/home` is the concrete `data/domain/presentation` feature template.
* build_runner generated files such as `*.g.dart`, `*.freezed.dart`, and `*.config.dart` must not be edited manually.
* On 2026-06-18, the project added an OKF v0.1 memory bundle at [okf-memory](/index.md).
* On 2026-06-21, Primitive Obsession / Type Safety guidance was added to agent rules, project skills, Cursor rules, and code standards.
* On 2026-07-01, current adaptive, accessibility, localization, performance, tablet, foldable, ChromeOS, iPad, and desktop-window guidance was aligned across project rules and docs.
* On 2026-07-27, presentation state moved to Signals 7 view models in one breaking cutover; session, connectivity, offline queue, permissions, and Home are signal-native.
* On 2026-07-27, the checked-in identity changed to `Flutter Agentic Starter`, `flutter_agentic_starter`, and `dev.example.flutteragenticstarter`.
