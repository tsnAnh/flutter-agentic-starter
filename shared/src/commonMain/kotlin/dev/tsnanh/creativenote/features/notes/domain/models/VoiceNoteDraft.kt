package dev.tsnanh.creativenote.features.notes.domain.models

data class VoiceNoteDraft(
    val id: String,
    val title: String,
    val summary: String,
    val transcript: String,
    val checklist: List<String> = emptyList(),
    val createdAtEpochMillis: Long,
    val durationMillis: Long,
    val source: NoteSource = NoteSource.Voice,
)
