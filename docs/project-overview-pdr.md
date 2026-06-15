# Project Overview PDR

## Goal

Provide a production-ready KMP starter optimized for AI coding agents and native mobile teams.

## Requirements

- Shared Kotlin architecture with feature/domain/data/presentation separation.
- Native Android and iOS UI.
- Koin DI, Ktor networking, typed async state, and reusable core service facades.
- Agent instructions for Claude Code, Codex, OpenCode, and Cursor.
- Secret-safe setup and app rename flow.

## Non-goals

- Shared Compose UI.
- Real app-specific Firebase/PostHog credentials.
- Production secure storage implementation without app signing/config decisions.
