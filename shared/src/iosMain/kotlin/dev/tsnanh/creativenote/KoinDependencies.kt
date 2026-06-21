package dev.tsnanh.creativenote

import dev.tsnanh.creativenote.features.notes.presentation.NotesViewModel
import org.koin.core.component.KoinComponent
import org.koin.core.component.inject

class KoinDependencies : KoinComponent {
    val notesViewModel: NotesViewModel by inject()
}
