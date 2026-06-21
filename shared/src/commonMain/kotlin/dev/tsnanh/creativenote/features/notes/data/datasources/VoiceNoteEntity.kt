package dev.tsnanh.creativenote.features.notes.data.datasources

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "voice_notes")
data class VoiceNoteEntity(
    @PrimaryKey val id: String,
    val title: String,
    val summary: String,
    val transcript: String,
    val checklist: String,
    val createdAtEpochMillis: Long,
    val durationMillis: Long,
    val source: String,
)
