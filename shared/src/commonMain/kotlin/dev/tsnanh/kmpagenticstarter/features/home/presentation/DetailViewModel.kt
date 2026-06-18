package dev.tsnanh.kmpagenticstarter.features.home.presentation

import arrow.core.Option
import arrow.core.none
import arrow.core.some
import com.rickclephas.kmp.nativecoroutines.NativeCoroutinesState
import com.rickclephas.kmp.observableviewmodel.ViewModel
import com.rickclephas.kmp.observableviewmodel.stateIn
import dev.tsnanh.kmpagenticstarter.core.base.AsyncResult
import dev.tsnanh.kmpagenticstarter.features.home.domain.models.MuseumObject
import dev.tsnanh.kmpagenticstarter.features.home.domain.usecases.ObserveMuseumObjectUseCase
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.flow.map

class DetailViewModel(private val observeMuseumObject: ObserveMuseumObjectUseCase) : ViewModel() {
    private val objectId = MutableStateFlow<Option<Int>>(none())

    @OptIn(ExperimentalCoroutinesApi::class)
    @NativeCoroutinesState
    val museumObjectResult: StateFlow<AsyncResult<Option<MuseumObject>>> = objectId
        .flatMapLatest { id ->
            id.fold(
                ifEmpty = { flowOf(none()) },
                ifSome = { observeMuseumObject(it).map { result -> result.some() } },
            )
        }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), none())

    @NativeCoroutinesState
    val museumObject: StateFlow<MuseumObject?> = museumObjectResult
        .map { state ->
            state.fold(
                ifEmpty = { null },
                ifSome = { result ->
                    result.fold(
                        ifLeft = { null },
                        ifRight = { option -> option.fold(ifEmpty = { null }, ifSome = { it }) },
                    )
                },
            )
        }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), null)

    @NativeCoroutinesState
    val museumObjectErrorMessage: StateFlow<String?> = museumObjectResult
        .map { state ->
            state.fold(
                ifEmpty = { null },
                ifSome = { result -> result.fold(ifLeft = { it.message }, ifRight = { null }) },
            )
        }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), null)

    fun setId(objectId: Int) {
        this.objectId.value = objectId.some()
    }
}
