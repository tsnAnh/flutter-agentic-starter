# creative-note

Kotlin Multiplatform voice-notes app. Built from JetBrains' native KMP app template, then adapted with Clean Architecture, shared Kotlin core modules, Android Jetpack Compose, SwiftUI, Koin DI, Room KMP storage, and an iOS-first local voice pipeline.

Package and platform ID: `dev.tsnanh.creativenote`.

## Features

- Native UI: Android Compose and iOS SwiftUI.
- Shared architecture: `core/`, `features/`, Koin DI, repositories, use cases, Arrow typed errors/options.
- Core modules: Room database, cache, auth/session, connectivity, offline queue, analytics, Firebase facades, permissions, lifecycle, routing, forms, logger, design tokens, utilities.
- Voice notes: shared note domain, generated checklists, repository, use cases, Room `voice_notes` storage, and Swift-friendly `NotesViewModel`.
- iOS recording: pull-to-record SwiftUI UI, detail backstack/editing, AVFoundation mic capture, first-use local MLX model setup, Qwen3-ASR transcription, and Qwen note drafting.
- Android v1: compile-ready notes list wired to shared storage; Android voice capture/model UI is intentionally deferred.
- Agent context: `AGENTS.md`, `CLAUDE.md`, `.claude/rules/`, `.cursor/rules/kmp.mdc`, `opencode.json`, and local skills.

The iOS app targets iOS 17+ because `mlx-audio-swift` requires it. Liquid Glass styling is gated behind iOS 26 availability with native material fallback below iOS 26.

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
shared/src/commonMain/kotlin/dev/tsnanh/creativenote/
  core/                  Shared infrastructure modules
  features/notes/        Voice-note domain/data/presentation folders
  di/                    Koin modules
androidApp/              Android Compose shell
iosApp/                  SwiftUI voice UI and local MLX pipeline
docs/                    Architecture and standards
```

## Verification

```sh
./gradlew :shared:allTests
./gradlew :androidApp:assembleDebug
./gradlew :shared:linkDebugFrameworkIosSimulatorArm64
./iosApp/patch-mlx-swift-gather-metal-validation.sh
xcodebuild -project iosApp/iosApp.xcodeproj -scheme iosApp -configuration Debug -destination 'generic/platform=iOS Simulator' -skipMacroValidation -skipPackagePluginValidation build
```

The Xcode flags skip local SwiftPM macro/plugin trust prompts for CI-style command-line builds.
The MLX patch script reapplies the same scalar-index Gather workaround that MLX already uses in Scatter; rerun it after resetting Swift packages or DerivedData.

## Attribution

This project is based on `Kotlin/KMP-App-Template-Native` and keeps its Apache-2.0 license.
