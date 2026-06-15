---
name: kmp-agentic-starter
description: >
  Project-specific Kotlin Multiplatform guidance for kmp-agentic-starter.
  Invoke first before working in this project.
  Use when editing shared Kotlin, Android Compose, SwiftUI, Koin DI, Ktor,
  models, tests, docs, or project setup in this repository.
---

# KMP Agentic Starter

Read repo docs first: `README.md`, `AGENTS.md` or `CLAUDE.md`, and relevant files in `docs/`.

## Core Rules

- Keep edits minimal and focused.
- Prefer maintained Kotlin/KMP packages before custom reusable utilities or integrations.
- Document package-first exceptions.
- Keep shared APIs Swift-friendly when consumed by iOS.
- Keep source files under 300 lines when practical.
- Never commit `.env`, API keys, Firebase plist/json, signing files, or tokens.

## Architecture

- Put shared infrastructure in `shared/src/commonMain/.../core/`.
- Put feature code in `shared/src/commonMain/.../features/<feature>/`.
- Use `DataState<T>` for async presentation state.
- Use repositories, use cases, Koin DI, and KMP ObservableViewModel.
- Keep Android UI in `androidApp`; keep iOS UI in `iosApp`.

## Verification

- Run `./gradlew :shared:allTests` after shared code/test changes.
- Run `./gradlew :androidApp:assembleDebug` after Android changes.
- Run `./gradlew :shared:linkDebugFrameworkIosSimulatorArm64` after shared/iOS bridge changes.
