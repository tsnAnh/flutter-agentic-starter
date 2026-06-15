# AGENTS.md

Guidance for agents working in this repository.

## Project

Name: `kmp-agentic-starter`
Type: Kotlin Multiplatform native app
Package: `dev.tsnanh.kmpagenticstarter`

Always invoke `kmp-agentic-starter` skill first before working here.

## Rules

- Read `README.md`, `AGENTS.md` or `CLAUDE.md`, and relevant docs before implementation.
- Keep edits minimal and focused. No unrelated rewrites, reorder, or formatting churn.
- Prefer maintained Kotlin/KMP packages before custom reusable utilities or integrations.
- Document package-first exceptions in plan/report/PR.
- Do not edit generated files or build outputs.
- Keep source files under 300 lines when practical.
- Never commit `.env`, API keys, Firebase plist/json, signing files, or tokens.
- Verify Kotlin changes with `./gradlew :shared:allTests`.
- Verify Android changes with `./gradlew :androidApp:assembleDebug`.
- Verify iOS bridge changes with `./gradlew :shared:linkDebugFrameworkIosSimulatorArm64` and Xcode build when possible.

## Architecture

- Shared Kotlin code owns business logic, core modules, repositories, use cases, and shared ViewModels.
- Android UI stays in `androidApp/` with Jetpack Compose.
- iOS UI stays in `iosApp/` with SwiftUI.
- Feature code goes under `shared/src/commonMain/.../features/<feature>/`.
- Core reusable modules go under `shared/src/commonMain/.../core/`.
- DI goes through Koin modules in `di/`.
