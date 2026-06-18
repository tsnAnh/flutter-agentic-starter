package dev.tsnanh.kmpagenticstarter.features.home.domain.repositories

import dev.tsnanh.kmpagenticstarter.core.base.AppResult
import dev.tsnanh.kmpagenticstarter.core.base.AsyncResult
import dev.tsnanh.kmpagenticstarter.core.base.OptionalResult
import dev.tsnanh.kmpagenticstarter.features.home.domain.models.MuseumObject
import kotlinx.coroutines.flow.Flow

interface MuseumRepository {
    suspend fun refresh(): AppResult<List<MuseumObject>>
    fun objects(): Flow<AsyncResult<List<MuseumObject>>>
    fun objectById(objectId: Int): Flow<OptionalResult<MuseumObject>>
}
