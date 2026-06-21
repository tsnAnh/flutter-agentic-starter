# Codebase Summary

`creative-note` is a native Kotlin Multiplatform voice-notes app.

- `shared`: Kotlin shared architecture, DI, core modules, notes domain, Room note storage, and `NotesViewModel`.
- `androidApp`: Android Compose notes list wired to shared storage.
- `iosApp`: SwiftUI pull-to-record voice UI, note detail/edit UI, AVFoundation recorder, and local MLX ASR/LM pipeline.
- `tools/projectSetup`: Gradle-run setup wizard.

Important package: `dev.tsnanh.creativenote`.

Current iOS models:

- ASR: `mlx-community/Qwen3-ASR-0.6B-4bit`
- LM: `mlx-community/Qwen3.5-0.8B-MLX-4bit`
