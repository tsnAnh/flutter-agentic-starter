package dev.tsnanh.creativenote.features.notes.domain.usecases

import dev.tsnanh.creativenote.core.base.AsyncResult
import dev.tsnanh.creativenote.features.notes.domain.models.VoiceNote
import dev.tsnanh.creativenote.features.notes.domain.repositories.NoteRepository
import kotlinx.coroutines.flow.Flow

class ObserveVoiceNotesUseCase(private val repository: NoteRepository) {
    operator fun invoke(): Flow<AsyncResult<List<VoiceNote>>> = repository.notes()
}
