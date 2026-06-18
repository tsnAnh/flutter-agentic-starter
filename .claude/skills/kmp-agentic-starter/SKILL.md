---
name: kmp-agentic-starter
description: Project-specific Kotlin Multiplatform guidance for kmp-agentic-starter.
---

# KMP Agentic Starter

Follow `README.md`, `AGENTS.md`, `CLAUDE.md`, and `docs/`.

- Minimal focused edits.
- Use `.agents/skills/manage-okf-memory` at start/end to maintain `okf-memory/`.
- Prefer maintained KMP packages.
- Shared code in `shared`; Android UI in `androidApp`; iOS UI in `iosApp`.
- Use `DataState`, repositories, use cases, Koin, and shared ViewModels.
- Verify with relevant Gradle/Xcode commands.
