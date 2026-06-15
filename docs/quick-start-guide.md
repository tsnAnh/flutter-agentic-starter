# Quick Start Guide

## Verify

```sh
./gradlew :shared:allTests
./gradlew :androidApp:assembleDebug
./gradlew :shared:linkDebugFrameworkIosSimulatorArm64
```

## Android

Open project in Android Studio and run `androidApp`.

## iOS

```sh
open iosApp/iosApp.xcodeproj
```

Run scheme `iosApp`.

## Rename App

```sh
./gradlew :tools:projectSetup:run --args='--app-name "Acme App" --kotlin-package-name dev.acme.app --app-id dev.acme.app --dry-run'
```
