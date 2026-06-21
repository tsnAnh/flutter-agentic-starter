package dev.tsnanh.creativenote.features.notes

import dev.tsnanh.creativenote.features.notes.data.toDomain
import dev.tsnanh.creativenote.features.notes.data.toEntity
import dev.tsnanh.creativenote.features.notes.domain.models.NoteSource
import dev.tsnanh.creativenote.features.notes.domain.models.VoiceNote
import kotlin.test.Test
import kotlin.test.assertEquals

class VoiceNoteMappersTest {
    @Test
    fun entityRoundTripKeepsStableSourceValue() {
        val domain = VoiceNote(
            id = "id",
            title = "Title",
            summary = "Summary",
            transcript = "Transcript",
            checklist = listOf("first", "second"),
            createdAtEpochMillis = 123,
            durationMillis = 1000,
            source = NoteSource.Voice,
        )

        val entity = domain.toEntity()

        assertEquals("voice", entity.source)
        assertEquals("first\nsecond", entity.checklist)
        assertEquals(domain, entity.toDomain())
    }
}
