# AGENTS.md

This file provides guidance to OpenCode when working with code in this repository.

## Project Overview

**Name:** flutter-agentic-starter
**Type:** Flutter/Dart
**Description:** Production-ready Flutter BLoC starter template optimized for AI coding agents. Clean architecture, 17 core modules, multi-flavor support. Built for vibe coding with Claude Code, Cursor, and other AI assistants.

## Role & Responsibilities

Your role is to analyze user requirements, delegate tasks to appropriate sub-agents, and ensure cohesive delivery of features that meet specifications and architectural standards.

## Workflows

- Primary workflow: `./.claude/rules/primary-workflow.md`
- Development rules: `./.claude/rules/development-rules.md`
- Orchestration protocols: `./.claude/rules/orchestration-protocol.md`
- Documentation management: `./.claude/rules/documentation-management.md`
- And other workflows: `./.claude/rules/*`

**IMPORTANT:** Analyze the skills catalog and activate the skills that are needed for the task during the process.
**IMPORTANT:** You must follow strictly the development rules in `./.claude/rules/development-rules.md` file.
**IMPORTANT:** Before you plan or proceed any implementation, always read the `./README.md` file first to get context.
**IMPORTANT:** Sacrifice grammar for the sake of concision when writing reports.
**IMPORTANT:** In reports, list any unresolved questions at the end, if any.

## Development Principles

- **YAGNI**: You Aren't Gonna Need It - avoid over-engineering
- **KISS**: Keep It Simple, Stupid - prefer simple solutions
- **DRY**: Don't Repeat Yourself - eliminate code duplication
- **Karpathy Guidelines**: Think before coding, keep changes simple, edit surgically, and define verifiable success criteria.

## Coding Agent Rules

- Read `README.md` and relevant docs before implementation.
- State assumptions when requirements are ambiguous; ask before risky guesses.
- **Hard rule:** Minimal focused edits only. Touch only files and lines required for requested behavior.
- **Hard rule:** Do not rewrite, reformat, reorder, regenerate, or clean up unrelated code unless required.
- **Hard rule:** Never manually edit build_runner generated files, including `*.g.dart`, `*.freezed.dart`, `*.config.dart`, or files marked `GENERATED CODE - DO NOT MODIFY BY HAND`.
- **Hard rule:** Prefer maintained pub.dev packages before implementing reusable Flutter/Dart utilities, widgets, integrations, or helpers yourself.
- Document any pub.dev package-first exception with reason.
- Keep repo-owned source code files under 300 lines when practical; split focused concerns when it improves readability.
- Respect dirty worktrees. Never revert user changes unless explicitly asked.
- Verify changes with `flutter analyze` and `flutter test` when code changes.
- For generated code changes, edit source files only, then run `dart run build_runner build --delete-conflicting-outputs`.
- Treat `.env`, API keys, tokens, and platform secrets as confidential.

## Documentation

Keep all important docs in `./docs` folder:

```
./docs
├── project-overview-pdr.md
├── code-standards.md
├── codebase-summary.md
├── design-guidelines.md
└── system-architecture.md
```

Root workflow files live in `./.claude/rules/`. Keep `AGENTS.md`,
`CLAUDE.md`, `.cursor/rules/flutter.mdc`, and docs aligned when structure
changes.

## External Files

Reference external instruction files in `opencode.json`:

```json
{
  "instructions": ["docs/*.md", ".opencode/agents/*.md"]
}
```

## Project Skills

Native project skills are provided for Claude Code, Codex, and OpenCode:

- Claude Code: `.claude/skills/`
- Codex: `.agents/skills/`
- OpenCode: `.opencode/skills/`

Available skills:

Always invoke `flutter-agentic-starter` first before working in this project.

- `flutter-agentic-starter`: Flutter, BLoC/Cubit, Clean Architecture, DI, routing, models, tests, and design system guidance.
- `caveman`: terse technical communication mode for concise reports.
- `frontend-design`: polished UI/frontend design guidance for user-facing surfaces.

---
