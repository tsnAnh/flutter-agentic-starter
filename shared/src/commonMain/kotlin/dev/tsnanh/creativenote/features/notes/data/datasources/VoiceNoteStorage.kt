package dev.tsnanh.creativenote.features.notes.data.datasources

import arrow.core.left
import arrow.core.right
import arrow.core.some
import dev.tsnanh.creativenote.core.base.AppResult
import dev.tsnanh.creativenote.core.base.AsyncResult
import dev.tsnanh.creativenote.core.base.BaseRepository
import dev.tsnanh.creativenote.core.error.toAppError
import dev.tsnanh.creativenote.features.notes.data.toDomain
import dev.tsnanh.creativenote.features.notes.data.toEntity
import dev.tsnanh.creativenote.features.notes.domain.models.VoiceNote
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.map
import kotlin.coroutines.cancellation.CancellationException

interface VoiceNoteStorage {
    suspend fun save(note: VoiceNote): AppResult<Unit>
    fun notes(): Flow<AsyncResult<List<VoiceNote>>>
}

class RoomVoiceNoteStorage(private val dao: VoiceNoteDao) : BaseRepository(), VoiceNoteStorage {
    override suspend fun save(note: VoiceNote): AppResult<Unit> =
        safeCall { dao.upsert(note.toEntity()) }

    override fun notes(): Flow<AsyncResult<List<VoiceNote>>> =
        dao.notes()
            .map { notes ->
                val result: AsyncResult<List<VoiceNote>> = notes.map { it.toDomain() }.right().some()
                result
            }
            .catch { error ->
                if (error is CancellationException) throw error
                val result: AsyncResult<List<VoiceNote>> = error.toAppError().left().some()
                emit(result)
            }
}

class InMemoryVoiceNoteStorage : VoiceNoteStorage {
    private val storedNotes = MutableStateFlow(emptyList<VoiceNote>())

    override suspend fun save(note: VoiceNote): AppResult<Unit> {
        storedNotes.value = (storedNotes.value.filterNot { it.id == note.id } + note)
            .sortedByDescending { it.createdAtEpochMillis }
        return Unit.right()
    }

    override fun notes(): Flow<AsyncResult<List<VoiceNote>>> =
        storedNotes.map {
            val result: AsyncResult<List<VoiceNote>> = it.right().some()
            result
        }
}
