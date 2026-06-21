---
name: manage-okf-memory
description: Manage this repository's OKF project memory bundle. Use at the start and end of work in creative-note, when maintaining okf-memory daily logs, rolling daily logs into base knowledge, or recording durable agent knowledge such as coding patterns, human style, requirements, decisions, major changes, and roadmap changes.
---

# Manage OKF Memory

Use `okf-memory/` as the source of truth. Keep it OKF v0.1 compatible: markdown files, YAML frontmatter on concept files, `index.md` and `log.md` reserved.

## Start Of Work

1. Run `date +%F`.
2. Read `okf-memory/index.md`, relevant `okf-memory/base/*.md`, and today's `okf-memory/daily/YYYY-MM-DD.md` if it exists.
3. Create today's daily file if no daily file exists.
4. If the latest `okf-memory/daily/*.md` file is not today, roll over before other edits.

## Rollover

For each prior daily file with `merged: false`:

1. Move durable entries into the matching base file:
   `coding-patterns`, `human-style`, `project-requirements`, `decision-changes`, `major-changes`, `roadmap`.
2. Deduplicate against existing base facts. Do not preserve transient debugging notes.
3. Set the daily file to `merged: true`.
4. Update changed base files with `timestamp` and `merged_through`.
5. Append a dated entry to `okf-memory/log.md`.
6. Create today's daily file with the same sections and `merged: false` if it does not exist.

## End Of Work

Update today's daily file only when there are new durable facts:

* Coding patterns agents should repeat.
* Human communication or report style preferences.
* Stable project requirements or verification rules.
* Accepted, rejected, or superseded decisions.
* Major repository changes.
* Roadmap changes.

Skip repeated facts, speculative ideas, temporary build logs, local paths with private values, secrets, tokens, credentials, and environment values. Put unresolved questions last.
