---
type: Project Memory
title: Major Changes
description: Significant repository changes agents should know before editing.
tags: [okf-memory, creative-note, major-changes]
timestamp: 2026-06-21T11:55:21+07:00
memory_category: major-changes
merged_through: 2026-06-18
---

# Current Major Changes

* The project is based on JetBrains' native KMP app template and adapted for Clean Architecture, Koin DI, Ktor, Room KMP, Arrow typed state, Android Compose, SwiftUI, and agent-ready rules.
* `features/home` is the concrete feature template.
* Room schema JSON files under `shared/schemas/` are generated migration history and should not be edited manually.
* On 2026-06-18, the project added an OKF v0.1 memory bundle at [okf-memory](/index.md).
