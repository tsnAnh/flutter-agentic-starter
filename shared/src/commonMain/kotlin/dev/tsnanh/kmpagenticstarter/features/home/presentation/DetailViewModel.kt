package dev.tsnanh.kmpagenticstarter.features.home.presentation

import com.rickclephas.kmp.nativecoroutines.NativeCoroutinesState
import com.rickclephas.kmp.observableviewmodel.ViewModel
import com.rickclephas.kmp.observableviewmodel.stateIn
import dev.tsnanh.kmpagenticstarter.core.base.DataState
import dev.tsnanh.kmpagenticstarter.features.home.domain.models.MuseumObject
import dev.tsnanh.kmpagenticstarter.features.home.domain.repositories.MuseumRepository
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.flow.map

class DetailViewModel(private val museumRepository: MuseumRepository) : ViewModel() {
    private val objectId = MutableStateFlow<Int?>(null)

    @OptIn(ExperimentalCoroutinesApi::class)
    @NativeCoroutinesState
    val museumObjectState: StateFlow<DataState<MuseumObject?>> = objectId
        .flatMapLatest { id -> id?.let { museumRepository.objectById(it) } ?: flowOf(DataState.Initial) }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), DataState.Initial)

    @NativeCoroutinesState
    val museumObject: StateFlow<MuseumObject?> = museumObjectState
        .map { state -> (state as? DataState.Loaded)?.data }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), null)

    fun setId(objectId: Int) {
        this.objectId.value = objectId
    }
}
