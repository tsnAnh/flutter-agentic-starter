package dev.tsnanh.creativenote.features.notes.data.repositories

import dev.tsnanh.creativenote.core.base.AppResult
import dev.tsnanh.creativenote.core.base.AsyncResult
import dev.tsnanh.creativenote.features.notes.data.datasources.VoiceNoteStorage
import dev.tsnanh.creativenote.features.notes.domain.models.VoiceNote
import dev.tsnanh.creativenote.features.notes.domain.repositories.NoteRepository
import kotlinx.coroutines.flow.Flow

class DefaultNoteRepository(private val storage: VoiceNoteStorage) : NoteRepository {
    override suspend fun save(note: VoiceNote): AppResult<Unit> = storage.save(note)

    override fun notes(): Flow<AsyncResult<List<VoiceNote>>> = storage.notes()
}
