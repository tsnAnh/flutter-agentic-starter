---
type: Project Memory
title: Project Requirements
description: Stable product, architecture, security, and verification requirements.
tags: [okf-memory, creative-note, requirements]
timestamp: 2026-06-21T11:55:21+07:00
memory_category: project-requirements
merged_through: 2026-06-18
---

# Current Requirements

* This repository is a production-ready Kotlin Multiplatform native app starter for AI coding agents.
* Package and platform ID: `dev.tsnanh.creativenote`.
* Agent-facing docs and skills are part of the product surface.
* Do not commit `.env`, API keys, Firebase plist/json, signing files, or tokens.
* Do not edit generated files or build outputs.
* Root `okf-memory/` is the project memory source of truth.
* Daily memory logs must record only new durable facts.
* Daily rollover is agent-managed at start/end of work.
* Keep source files under 300 lines when practical.
* Verify shared Kotlin changes with `./gradlew :shared:allTests`.
* Verify Android changes with `./gradlew :androidApp:assembleDebug`.
* Verify shared/iOS bridge changes with `./gradlew :shared:linkDebugFrameworkIosSimulatorArm64`.
