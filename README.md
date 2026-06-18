# kmp-agentic-starter

Production-ready Kotlin Multiplatform starter for AI coding agents. Built from JetBrains' native KMP app template, then adapted with Clean Architecture, shared Kotlin core modules, Android Jetpack Compose, SwiftUI, Koin DI, Ktor networking, Room KMP storage, and agent-ready project rules.

Package and platform ID: `dev.tsnanh.kmpagenticstarter`.

## Features

- Native UI: Android Compose and iOS SwiftUI.
- Shared architecture: `core/`, `features/`, Koin DI, repositories, use cases, Arrow typed errors/options.
- Core modules: network, Room database, cache, auth/session, connectivity, offline queue, analytics, Firebase facades, permissions, lifecycle, routing, forms, logger, design tokens, utilities.
- Sample feature: Museum object list/detail ported into `features/home`.
- Agent context: `AGENTS.md`, `CLAUDE.md`, `.claude/rules/`, `.cursor/rules/kmp.mdc`, `opencode.json`, and local skills.

## Quick Start

```sh
./gradlew :shared:allTests
./gradlew :androidApp:assembleDebug
./gradlew :shared:linkDebugFrameworkIosSimulatorArm64
open iosApp/iosApp.xcodeproj
```

Run Android from Android Studio using `androidApp`. Run iOS from Xcode using `iosApp`.

## Setup Wizard

Preview rename:

```sh
./gradlew :tools:projectSetup:run --args='--app-name "Acme App" --kotlin-package-name dev.acme.app --app-id dev.acme.app --dry-run'
```

Apply rename:

```sh
./gradlew :tools:projectSetup:run --args='--app-name "Acme App" --kotlin-package-name dev.acme.app --app-id dev.acme.app'
```

The script creates `.env` only if missing. `.env`, `google-services.json`, and `GoogleService-Info.plist` are ignored.

## Structure

```text
shared/src/commonMain/kotlin/dev/tsnanh/kmpagenticstarter/
  core/                  Shared infrastructure modules
  features/home/         Feature template with domain/data/presentation folders
  di/                    Koin modules
androidApp/              Android Compose shell
iosApp/                  SwiftUI shell
docs/                    Architecture and standards
```

## Verification

```sh
./gradlew :shared:allTests
./gradlew :androidApp:assembleDebug
./gradlew :shared:linkDebugFrameworkIosSimulatorArm64
xcodebuild -project iosApp/iosApp.xcodeproj -scheme iosApp -configuration Debug -destination 'generic/platform=iOS Simulator' build
```

## Attribution

This project is based on `Kotlin/KMP-App-Template-Native` and keeps its Apache-2.0 license.
