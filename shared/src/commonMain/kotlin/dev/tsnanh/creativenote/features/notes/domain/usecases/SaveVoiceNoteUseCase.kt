package dev.tsnanh.creativenote.features.notes.domain.usecases

import arrow.core.left
import arrow.core.raise.either
import dev.tsnanh.creativenote.core.base.AppResult
import dev.tsnanh.creativenote.core.error.AppError
import dev.tsnanh.creativenote.features.notes.domain.models.VoiceNote
import dev.tsnanh.creativenote.features.notes.domain.models.VoiceNoteDraft
import dev.tsnanh.creativenote.features.notes.domain.repositories.NoteRepository

class SaveVoiceNoteUseCase(private val repository: NoteRepository) {
    suspend operator fun invoke(draft: VoiceNoteDraft): AppResult<VoiceNote> {
        val transcript = draft.transcript.trim()
        if (transcript.isBlank()) {
            return AppError("Transcript is required", code = "blank_transcript").left()
        }
        val checklist = draft.checklist.map { it.trim() }.filter { it.isNotBlank() }

        return either {
            val note = VoiceNote(
                id = draft.id.ifBlank { draft.createdAtEpochMillis.toString() },
                title = draft.title.trim().ifBlank { "Untitled note" },
                summary = draft.summary.trim().ifBlank { transcript },
                transcript = transcript,
                checklist = checklist,
                createdAtEpochMillis = draft.createdAtEpochMillis,
                durationMillis = draft.durationMillis.coerceAtLeast(0),
                source = draft.source,
            )
            repository.save(note).bind()
            note
        }
    }
}
