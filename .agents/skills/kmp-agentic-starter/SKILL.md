---
name: kmp-agentic-starter
description: >
  Project-specific Kotlin Multiplatform guidance for kmp-agentic-starter.
  Invoke first before working in this project.
  Use when editing shared Kotlin, Android Compose, SwiftUI, Koin DI, Ktor,
  Arrow typed errors/options, models, tests, docs, or project setup in this repository.
---

# KMP Agentic Starter

Read repo docs first: `README.md`, `AGENTS.md` or `CLAUDE.md`, and relevant files in `docs/`.

## Core Rules

- Use `manage-okf-memory` at the start and end of work to read or update `okf-memory/`.
- Keep edits minimal and focused.
- Prefer maintained Kotlin/KMP packages before custom reusable utilities or integrations.
- Document package-first exceptions.
- Keep shared APIs Swift-friendly when consumed by iOS.
- Use Arrow Kotlin for shared result/null/validation boundaries.
- Keep source files under 300 lines when practical.
- Never commit `.env`, API keys, Firebase plist/json, signing files, or tokens.

## Arrow Kotlin Rules

- Prefer `AppResult<T>`, `AsyncResult<T>`, and `OptionalResult<T>` from `core/base` over custom result/loading/null wrappers.
- Use `Either<AppError, T>` for typed failures and `Option<T>` for absence at shared public boundaries.
- Keep Swift-friendly derived flows/properties when Arrow types are awkward for SwiftUI.
- Use `either { ... bind() ... }` for repository/use case composition.
- Use `EitherNel<String, Unit>` for validation when accumulating multiple errors.
- Use Arrow Optics only on plain shared models; do not annotate DTOs, Room entities, generated files, or platform UI.
- Use Arrow Resilience for real retry/backoff needs only; do not add fake `parZip`/`parMap` just to exercise Arrow FX.

## Architecture

- Put shared infrastructure in `shared/src/commonMain/.../core/`.
- Put feature code in `shared/src/commonMain/.../features/<feature>/`.
- Use Arrow typed errors/options for async presentation state.
- Use repositories, use cases, Koin DI, and KMP ObservableViewModel.
- Keep Android UI in `androidApp`; keep iOS UI in `iosApp`.

## Verification

- Run `./gradlew :shared:allTests` after shared code/test changes.
- Run `./gradlew :androidApp:assembleDebug` after Android changes.
- Run `./gradlew :shared:linkDebugFrameworkIosSimulatorArm64` after shared/iOS bridge changes.
