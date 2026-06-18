package dev.tsnanh.kmpagenticstarter.features.home.presentation

import arrow.core.left
import arrow.core.none
import arrow.core.Option
import arrow.core.some
import com.rickclephas.kmp.nativecoroutines.NativeCoroutinesState
import com.rickclephas.kmp.observableviewmodel.ViewModel
import com.rickclephas.kmp.observableviewmodel.launch
import com.rickclephas.kmp.observableviewmodel.stateIn
import dev.tsnanh.kmpagenticstarter.core.base.AsyncResult
import dev.tsnanh.kmpagenticstarter.core.error.AppError
import dev.tsnanh.kmpagenticstarter.features.home.domain.models.MuseumObject
import dev.tsnanh.kmpagenticstarter.features.home.domain.usecases.GetMuseumObjectsUseCase
import dev.tsnanh.kmpagenticstarter.features.home.domain.usecases.ObserveMuseumObjectsUseCase
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow

class ListViewModel(
    private val getMuseumObjects: GetMuseumObjectsUseCase,
    observeMuseumObjects: ObserveMuseumObjectsUseCase,
) : ViewModel() {
    private val refreshError = MutableStateFlow<Option<AppError>>(none())

    @NativeCoroutinesState
    val objectsResult: StateFlow<AsyncResult<List<MuseumObject>>> =
        observeMuseumObjects().combine(refreshError) { objects, error ->
            error.fold(
                ifEmpty = { objects },
                ifSome = { it.left().some() },
            )
        }
            .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), none())

    @NativeCoroutinesState
    val objects: StateFlow<List<MuseumObject>> = objectsResult
        .map { state ->
            state.fold(
                ifEmpty = { emptyList() },
                ifSome = { result -> result.fold(ifLeft = { emptyList() }, ifRight = { it }) },
            )
        }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptyList())

    @NativeCoroutinesState
    val objectsErrorMessage: StateFlow<String?> = objectsResult
        .map { state ->
            state.fold(
                ifEmpty = { null },
                ifSome = { result -> result.fold(ifLeft = { it.message }, ifRight = { null }) },
            )
        }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), null)

    init {
        refresh()
    }

    fun refresh() {
        viewModelScope.launch {
            getMuseumObjects().fold(
                ifLeft = { refreshError.value = it.some() },
                ifRight = { refreshError.value = none() },
            )
        }
    }
}
