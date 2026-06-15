# CLAUDE.md

Use `AGENTS.md` as primary guidance.

## Hard Rules

- Invoke `kmp-agentic-starter` skill first.
- Minimal focused edits only.
- Prefer maintained KMP libraries before custom reusable code.
- Do not commit secrets or platform credentials.
- Do not manually edit generated outputs.
- Keep KMP shared APIs Swift-friendly when they cross into iOS UI.

## Verification

Run relevant checks:

```sh
./gradlew :shared:allTests
./gradlew :androidApp:assembleDebug
./gradlew :shared:linkDebugFrameworkIosSimulatorArm64
```
