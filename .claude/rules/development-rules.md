# Development Rules

## Principles

- YAGNI, KISS, DRY.
- Karpathy Guidelines: think before coding, keep simple, edit surgically, verify concrete goals.

## Non-Negotiable Rules

- Minimal focused edits are mandatory: touch only files and lines required for the requested behavior.
- Do not rewrite, reformat, reorder, regenerate, or clean up unrelated code unless required by the task.
- Do not create enhanced replacement files; update existing files directly.
- Never manually edit build_runner generated files, including `*.g.dart`, `*.freezed.dart`, `*.config.dart`, or files marked `GENERATED CODE - DO NOT MODIFY BY HAND`.
- Package-first is mandatory for Flutter/Dart: check and prefer maintained pub.dev packages before implementing reusable utilities, widgets, integrations, or helpers yourself.
- Custom Flutter/Dart implementation is allowed only when no suitable package exists, or when packages fail security, privacy, license, platform, size, performance, or architecture requirements.
- Document any package-first exception in the plan, report, PR, or code review summary.
- For Flutter source icons/images, find suitable existing internet assets instead of creating them yourself. Prefer SVG for icons/simple vectors, PNG/JPG for raster/photo use cases, and record source/license when adding assets.

## Editing

- Use smallest correct patch.
- Preserve existing structure, comments, naming, and formatting unless change requires it.
- Do not revert user changes in dirty worktrees.
- Do not commit secrets, `.env`, API keys, or credentials.
- Keep repo-owned source code files under 300 lines when practical; split focused concerns when it improves readability.
- Do not split generated files, docs, configs, assets, lockfiles, or build artifacts for line count alone.

## Verification

- Run `flutter analyze` after code changes.
- Run `flutter test` after behavior/test changes.
- For injectable, Freezed, or JSON model changes, edit source files only, then run `dart run build_runner build --delete-conflicting-outputs`.
