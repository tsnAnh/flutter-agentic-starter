package dev.tsnanh.kmpagenticstarter.features.home.presentation

import com.rickclephas.kmp.nativecoroutines.NativeCoroutinesState
import com.rickclephas.kmp.observableviewmodel.ViewModel
import com.rickclephas.kmp.observableviewmodel.stateIn
import dev.tsnanh.kmpagenticstarter.core.base.DataState
import dev.tsnanh.kmpagenticstarter.features.home.domain.models.MuseumObject
import dev.tsnanh.kmpagenticstarter.features.home.domain.repositories.MuseumRepository
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow

class ListViewModel(museumRepository: MuseumRepository) : ViewModel() {
    @NativeCoroutinesState
    val objectsState: StateFlow<DataState<List<MuseumObject>>> =
        museumRepository.objects()
            .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), DataState.Loading)

    @NativeCoroutinesState
    val objects: StateFlow<List<MuseumObject>> = objectsState
        .map { state -> (state as? DataState.Loaded)?.data.orEmpty() }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptyList())
}
