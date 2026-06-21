package dev.tsnanh.creativenote.features.notes

import arrow.core.Either
import dev.tsnanh.creativenote.features.notes.data.datasources.InMemoryVoiceNoteStorage
import dev.tsnanh.creativenote.features.notes.data.repositories.DefaultNoteRepository
import dev.tsnanh.creativenote.features.notes.domain.models.VoiceNoteDraft
import dev.tsnanh.creativenote.features.notes.domain.usecases.SaveVoiceNoteUseCase
import kotlinx.coroutines.test.runTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class SaveVoiceNoteUseCaseTest {
    @Test
    fun rejectsBlankTranscript() = runTest {
        val useCase = SaveVoiceNoteUseCase(DefaultNoteRepository(InMemoryVoiceNoteStorage()))

        val state = useCase(draft(transcript = " "))

        assertTrue(state is Either.Left)
        assertEquals("blank_transcript", state.value.code)
    }

    @Test
    fun trimsAndDefaultsGeneratedFields() = runTest {
        val useCase = SaveVoiceNoteUseCase(DefaultNoteRepository(InMemoryVoiceNoteStorage()))

        val state = useCase(
            draft(
                title = " ",
                summary = " ",
                transcript = " raw text ",
                checklist = listOf(" call Sam ", " ", "send recap"),
            ),
        )

        assertTrue(state is Either.Right)
        assertEquals("Untitled note", state.value.title)
        assertEquals("raw text", state.value.summary)
        assertEquals("raw text", state.value.transcript)
        assertEquals(listOf("call Sam", "send recap"), state.value.checklist)
    }

    private fun draft(
        title: String = "Title",
        summary: String = "Summary",
        transcript: String = "Transcript",
        checklist: List<String> = emptyList(),
    ) = VoiceNoteDraft(
        id = "1",
        title = title,
        summary = summary,
        transcript = transcript,
        checklist = checklist,
        createdAtEpochMillis = 123,
        durationMillis = 1000,
    )
}
