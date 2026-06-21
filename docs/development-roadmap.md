# Development Roadmap

## Current

- iOS-first voice notes branch.
- Shared Clean Architecture foundations.
- Room KMP persistent storage for `voice_notes`.
- Shared note repository, checklist-capable use cases, typed save errors, and `NotesViewModel`.
- iOS pull-to-record SwiftUI experience with local Qwen3-ASR and Qwen MLX processing.
- iOS detail backstack with generated checklist display and voice-first note editing.
- Android notes list kept compile-ready for stored notes.
- Agent docs/rules/skills.

## Next

- Manual iOS QA for first-use model setup, mic permission denied/granted, pull cancel/save, persistence after relaunch, reduced motion, iOS 26 Liquid Glass, and pre-iOS 26 fallback.
- Add Android voice capture/model UI behind the same `VoiceNoteDraft` boundary.
- Add persisted checklist completion, search, delete, tags, and sync when requested.
- Add product-grade model download progress and retry UX if first-use setup needs more polish.
