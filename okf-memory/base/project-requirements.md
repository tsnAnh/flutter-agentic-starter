---
type: Project Memory
title: Project Requirements
description: Stable product, architecture, security, and verification requirements.
tags: [okf-memory, kmp-agentic-starter, requirements]
timestamp: 2026-06-18T15:59:05+07:00
memory_category: project-requirements
merged_through: null
---

# Current Requirements

* This repository is a production-ready Kotlin Multiplatform native app starter for AI coding agents.
* Package and platform ID: `dev.tsnanh.kmpagenticstarter`.
* Agent-facing docs and skills are part of the product surface.
* Do not commit `.env`, API keys, Firebase plist/json, signing files, or tokens.
* Do not edit generated files or build outputs.
* Keep source files under 300 lines when practical.
* Verify shared Kotlin changes with `./gradlew :shared:allTests`.
* Verify Android changes with `./gradlew :androidApp:assembleDebug`.
* Verify shared/iOS bridge changes with `./gradlew :shared:linkDebugFrameworkIosSimulatorArm64`.
