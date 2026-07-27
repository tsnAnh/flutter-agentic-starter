---
type: Project Memory
title: Project Requirements
description: Stable product, architecture, security, and verification requirements.
tags: [okf-memory, flutter-agentic-starter, requirements]
timestamp: 2026-07-27T00:00:00+07:00
memory_category: project-requirements
merged_through: 2026-07-27
---

# Current Requirements

* This repository is a production-ready Flutter Signals starter template for AI coding agents.
* Product name: `Flutter Agentic Starter`; Dart package: `flutter_agentic_starter`; organization: `Example`; application ID: `dev.example.flutteragenticstarter`.
* Signals 7 is the sole reactive presentation core; no compatibility adapters are retained.
* Authentication state is volatile and every app process starts signed out.
* Agent-facing docs and skills are part of the product surface.
* Agent-facing typed-domain guidance must stay aligned across Claude, Codex, OpenCode, Cursor, and docs surfaces.
* Flutter best-practice guidance must stay aligned across project skills, top-level agent docs, Cursor rules, Claude development rules, and code standards.
* Root `okf-memory/` is the project memory source of truth.
* Daily memory logs must record only new durable facts.
* Daily rollover is agent-managed at start/end of work.
* Do not commit `.env`, API keys, Firebase plist/json, signing files, or tokens.
* Do not edit generated files or build outputs.
* Keep source files under 300 lines when practical.
* Run `flutter analyze` after Dart code changes.
* Run `flutter test` after behavior or test changes.
* Run `dart run build_runner build --delete-conflicting-outputs` after Injectable, Freezed, or JSON model changes.
* Keep GetIt/Injectable, GoRouter, repositories, Dio, Hive, Freezed, and fpdart as the supporting architecture.
