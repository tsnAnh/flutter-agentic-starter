package dev.tsnanh.creativenote.features.notes.domain.models

enum class NoteSource(val storageValue: String) {
    Voice("voice");

    companion object {
        fun fromStorage(value: String): NoteSource =
            entries.firstOrNull { it.storageValue == value } ?: Voice
    }
}
