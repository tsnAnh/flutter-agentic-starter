package dev.tsnanh.creativenote.features.notes.presentation

import arrow.core.left
import arrow.core.none
import arrow.core.Option
import arrow.core.some
import com.rickclephas.kmp.nativecoroutines.NativeCoroutinesState
import com.rickclephas.kmp.observableviewmodel.ViewModel
import com.rickclephas.kmp.observableviewmodel.launch
import com.rickclephas.kmp.observableviewmodel.stateIn
import dev.tsnanh.creativenote.core.base.AsyncResult
import dev.tsnanh.creativenote.core.error.AppError
import dev.tsnanh.creativenote.features.notes.domain.models.VoiceNote
import dev.tsnanh.creativenote.features.notes.domain.models.VoiceNoteDraft
import dev.tsnanh.creativenote.features.notes.domain.usecases.ObserveVoiceNotesUseCase
import dev.tsnanh.creativenote.features.notes.domain.usecases.SaveVoiceNoteUseCase
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow

class NotesViewModel(
    observeVoiceNotes: ObserveVoiceNotesUseCase,
    private val saveVoiceNoteUseCase: SaveVoiceNoteUseCase,
) : ViewModel() {
    private val saveError = MutableStateFlow<Option<AppError>>(none())

    @NativeCoroutinesState
    val notesResult: StateFlow<AsyncResult<List<VoiceNote>>> =
        observeVoiceNotes().combine(saveError) { notes, error ->
            error.fold(
                ifEmpty = { notes },
                ifSome = { it.left().some() },
            )
        }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), none())

    @NativeCoroutinesState
    val notes: StateFlow<List<VoiceNote>> = notesResult
        .map { state ->
            state.fold(
                ifEmpty = { emptyList() },
                ifSome = { result -> result.fold(ifLeft = { emptyList() }, ifRight = { it }) },
            )
        }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptyList())

    @NativeCoroutinesState
    val notesErrorMessage: StateFlow<String?> = notesResult
        .map { state ->
            state.fold(
                ifEmpty = { null },
                ifSome = { result -> result.fold(ifLeft = { it.message }, ifRight = { null }) },
            )
        }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), null)

    fun saveVoiceNote(draft: VoiceNoteDraft) {
        viewModelScope.launch {
            saveVoiceNoteUseCase(draft).fold(
                ifLeft = { saveError.value = it.some() },
                ifRight = { saveError.value = none() },
            )
        }
    }
}
