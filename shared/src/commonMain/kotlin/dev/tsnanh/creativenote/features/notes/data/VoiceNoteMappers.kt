package dev.tsnanh.creativenote.features.notes.data

import dev.tsnanh.creativenote.features.notes.data.datasources.VoiceNoteEntity
import dev.tsnanh.creativenote.features.notes.domain.models.NoteSource
import dev.tsnanh.creativenote.features.notes.domain.models.VoiceNote

internal fun VoiceNote.toEntity() = VoiceNoteEntity(
    id = id,
    title = title,
    summary = summary,
    transcript = transcript,
    checklist = checklist.toChecklistStorage(),
    createdAtEpochMillis = createdAtEpochMillis,
    durationMillis = durationMillis,
    source = source.storageValue,
)

internal fun VoiceNoteEntity.toDomain() = VoiceNote(
    id = id,
    title = title,
    summary = summary,
    transcript = transcript,
    checklist = checklist.toChecklistItems(),
    createdAtEpochMillis = createdAtEpochMillis,
    durationMillis = durationMillis,
    source = NoteSource.fromStorage(source),
)

private fun List<String>.toChecklistStorage(): String =
    map { it.trim() }.filter { it.isNotBlank() }.joinToString("\n")

private fun String.toChecklistItems(): List<String> =
    lineSequence().map { it.trim() }.filter { it.isNotBlank() }.toList()
