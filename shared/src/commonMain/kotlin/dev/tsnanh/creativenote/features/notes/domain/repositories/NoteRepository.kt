package dev.tsnanh.creativenote.features.notes.domain.repositories

import dev.tsnanh.creativenote.core.base.AppResult
import dev.tsnanh.creativenote.core.base.AsyncResult
import dev.tsnanh.creativenote.features.notes.domain.models.VoiceNote
import kotlinx.coroutines.flow.Flow

interface NoteRepository {
    suspend fun save(note: VoiceNote): AppResult<Unit>
    fun notes(): Flow<AsyncResult<List<VoiceNote>>>
}
