---
name: kmp-agentic-starter
description: Project-specific Kotlin Multiplatform guidance for kmp-agentic-starter.
---

# KMP Agentic Starter

Follow `README.md`, `AGENTS.md`, `CLAUDE.md`, and `docs/`.

- Minimal focused edits.
- Use `.agents/skills/manage-okf-memory` at start/end to maintain `okf-memory/`.
- Prefer maintained KMP packages.
- Avoid primitive obsession with platform/library types, `enum class`, sealed types, `@JvmInline value class`, and Arrow `Either`/`Option`; parse raw strings/ints at boundaries and never persist enum `ordinal`.
- Shared code in `shared`; Android UI in `androidApp`; iOS UI in `iosApp`.
- Use `DataState`, repositories, use cases, Koin, and shared ViewModels.
- Verify with relevant Gradle/Xcode commands.
