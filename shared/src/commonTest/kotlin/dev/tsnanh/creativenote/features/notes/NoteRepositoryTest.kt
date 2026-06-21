package dev.tsnanh.creativenote.features.notes

import arrow.core.Either
import arrow.core.Some
import dev.tsnanh.creativenote.features.notes.data.datasources.InMemoryVoiceNoteStorage
import dev.tsnanh.creativenote.features.notes.data.repositories.DefaultNoteRepository
import dev.tsnanh.creativenote.features.notes.domain.models.NoteSource
import dev.tsnanh.creativenote.features.notes.domain.models.VoiceNote
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.runTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class NoteRepositoryTest {
    @Test
    fun saveAndObserveNotesNewestFirst() = runTest {
        val repository = DefaultNoteRepository(InMemoryVoiceNoteStorage())

        repository.save(note(id = "old", createdAt = 1))
        repository.save(note(id = "new", createdAt = 2))

        val state = repository.notes().first()
        assertTrue(state is Some)
        val result = state.value
        assertTrue(result is Either.Right)
        assertEquals(listOf("new", "old"), result.value.map { it.id })
    }

    private fun note(id: String, createdAt: Long) = VoiceNote(
        id = id,
        title = "Title",
        summary = "Summary",
        transcript = "Transcript",
        checklist = emptyList(),
        createdAtEpochMillis = createdAt,
        durationMillis = 1000,
        source = NoteSource.Voice,
    )
}
