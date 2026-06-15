package dev.tsnanh.kmpagenticstarter.features.home.data.datasources

import dev.tsnanh.kmpagenticstarter.features.home.domain.models.MuseumObject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.map

interface MuseumStorage {
    suspend fun saveObjects(objects: List<MuseumObject>)
    fun objects(): Flow<List<MuseumObject>>
    fun objectById(objectId: Int): Flow<MuseumObject?>
}

class InMemoryMuseumStorage : MuseumStorage {
    private val storedObjects = MutableStateFlow(emptyList<MuseumObject>())

    override suspend fun saveObjects(objects: List<MuseumObject>) {
        storedObjects.value = objects
    }

    override fun objects(): Flow<List<MuseumObject>> = storedObjects

    override fun objectById(objectId: Int): Flow<MuseumObject?> =
        storedObjects.map { objects -> objects.firstOrNull { it.objectID == objectId } }
}
