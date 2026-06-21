# Development Rules

- YAGNI, KISS, DRY.
- Minimal focused edits only.
- Prefer maintained Kotlin/KMP packages before custom reusable code.
- Avoid primitive obsession: use platform/library types, `enum class`, sealed types, `@JvmInline value class`, and Arrow `Either`/`Option` for finite or high-risk domain concepts. Parse raw strings/ints at API, config, route, storage, and serialization boundaries; never persist enum `ordinal`.
- Do not edit generated files or build outputs.
- Do not commit `.env`, API keys, Firebase plist/json, signing files, or tokens.
- Keep source files under 300 lines when practical.
- Run `./gradlew :shared:allTests` after shared code changes.
- Run `./gradlew :androidApp:assembleDebug` after Android changes.
- Run `./gradlew :shared:linkDebugFrameworkIosSimulatorArm64` after iOS shared API changes.
