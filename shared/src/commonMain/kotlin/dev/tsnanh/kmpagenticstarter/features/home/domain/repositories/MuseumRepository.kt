package dev.tsnanh.kmpagenticstarter.features.home.domain.repositories

import dev.tsnanh.kmpagenticstarter.core.base.DataState
import dev.tsnanh.kmpagenticstarter.features.home.domain.models.MuseumObject
import kotlinx.coroutines.flow.Flow

interface MuseumRepository {
    suspend fun refresh(): DataState<List<MuseumObject>>
    fun objects(): Flow<DataState<List<MuseumObject>>>
    fun objectById(objectId: Int): Flow<DataState<MuseumObject?>>
}
