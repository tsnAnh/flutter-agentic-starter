---
type: Project Memory
title: Decision Changes
description: Accepted or superseded decisions that change future implementation choices.
tags: [okf-memory, flutter-agentic-starter, decisions]
timestamp: 2026-07-27T00:00:00+07:00
memory_category: decision-changes
merged_through: 2026-07-27
---

# Current Decisions

* Use a root [OKF memory bundle](/index.md) as the durable project memory source of truth.
* Organize consolidated long-term memory by category files under [base](/base/), not one monolithic base file.
* Manage daily rollover through agent skill instructions, not an app runtime change or automation script.
* Keep OKF memory docs-only: no Flutter app runtime or package dependency changes.
* Aggressive typing is a future-code guardrail first, not a retroactive app-wide refactor unless explicitly requested.
* Signals 7 is the only reactive presentation architecture. Use feature view models with private `Signal` state and public `ReadonlySignal` exposure; do not add compatibility adapters or a base view-model hierarchy.
* Session authentication is intentionally volatile until platform secure storage is implemented.
* `signals_lint` is enabled as an analyzer plugin. It requires the compatible Injectable 3 and Freezed 4 prerelease generator line until Freezed 4 is stable.
