package dev.tsnanh.kmpagenticstarter.features.home.data.repositories

import dev.tsnanh.kmpagenticstarter.core.base.BaseRepository
import dev.tsnanh.kmpagenticstarter.core.base.DataState
import dev.tsnanh.kmpagenticstarter.features.home.data.datasources.MuseumApi
import dev.tsnanh.kmpagenticstarter.features.home.data.datasources.MuseumStorage
import dev.tsnanh.kmpagenticstarter.features.home.domain.models.MuseumObject
import dev.tsnanh.kmpagenticstarter.features.home.domain.repositories.MuseumRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.launch

class DefaultMuseumRepository(
    private val api: MuseumApi,
    private val storage: MuseumStorage,
) : BaseRepository(), MuseumRepository {
    private val scope = CoroutineScope(SupervisorJob())

    fun initialize() {
        scope.launch { refresh() }
    }

    override suspend fun refresh(): DataState<List<MuseumObject>> =
        safeCall {
            val objects = api.getObjects()
            storage.saveObjects(objects)
            objects
        }

    override fun objects(): Flow<DataState<List<MuseumObject>>> =
        storage.objects().map { objects ->
            if (objects.isEmpty()) DataState.Loading else DataState.Loaded(objects)
        }

    override fun objectById(objectId: Int): Flow<DataState<MuseumObject?>> =
        storage.objectById(objectId).map { DataState.Loaded(it) }
}
