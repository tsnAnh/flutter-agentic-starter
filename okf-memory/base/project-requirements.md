---
type: Project Memory
title: Project Requirements
description: Stable product, architecture, security, and verification requirements.
tags: [okf-memory, flutter-agentic-starter, requirements]
timestamp: 2026-06-21T11:34:45+07:00
memory_category: project-requirements
merged_through: 2026-06-18
---

# Current Requirements

* This repository is a production-ready Flutter BLoC starter template for AI coding agents.
* Project name: `flutter-agentic-starter`.
* Agent-facing docs and skills are part of the product surface.
* Root `okf-memory/` is the project memory source of truth.
* Daily memory logs must record only new durable facts.
* Daily rollover is agent-managed at start/end of work.
* Do not commit `.env`, API keys, Firebase plist/json, signing files, or tokens.
* Do not edit generated files or build outputs.
* Keep source files under 300 lines when practical.
* Run `flutter analyze` after Dart code changes.
* Run `flutter test` after behavior or test changes.
* Run `dart run build_runner build --delete-conflicting-outputs` after Injectable, Freezed, or JSON model changes.
