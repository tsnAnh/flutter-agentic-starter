package dev.tsnanh.kmpagenticstarter.features.home.data.datasources

import arrow.core.left
import arrow.core.none
import arrow.core.right
import arrow.core.some
import arrow.core.toOption
import dev.tsnanh.kmpagenticstarter.core.base.AppResult
import dev.tsnanh.kmpagenticstarter.core.base.BaseRepository
import dev.tsnanh.kmpagenticstarter.core.base.OptionalResult
import dev.tsnanh.kmpagenticstarter.core.error.toAppError
import dev.tsnanh.kmpagenticstarter.features.home.data.toDomain
import dev.tsnanh.kmpagenticstarter.features.home.data.toEntity
import dev.tsnanh.kmpagenticstarter.features.home.domain.models.MuseumObject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.map
import kotlin.coroutines.cancellation.CancellationException

interface MuseumStorage {
    suspend fun saveObjects(objects: List<MuseumObject>): AppResult<Unit>
    fun objects(): Flow<OptionalResult<List<MuseumObject>>>
    fun objectById(objectId: Int): Flow<OptionalResult<MuseumObject>>
}

class RoomMuseumStorage(private val dao: MuseumObjectDao) : BaseRepository(), MuseumStorage {
    override suspend fun saveObjects(objects: List<MuseumObject>): AppResult<Unit> =
        safeCall { dao.replaceObjects(objects.map { it.toEntity() }) }

    override fun objects(): Flow<OptionalResult<List<MuseumObject>>> =
        dao.objects()
            .map { objects ->
                val domainObjects = objects.map { it.toDomain() }
                val result: OptionalResult<List<MuseumObject>> =
                    if (domainObjects.isEmpty()) none<List<MuseumObject>>().right() else domainObjects.some().right()
                result
            }
            .catch { error ->
                if (error is CancellationException) throw error
                val result: OptionalResult<List<MuseumObject>> = error.toAppError().left()
                emit(result)
            }

    override fun objectById(objectId: Int): Flow<OptionalResult<MuseumObject>> =
        dao.objectById(objectId)
            .map {
                val result: OptionalResult<MuseumObject> = it?.toDomain().toOption().right()
                result
            }
            .catch { error ->
                if (error is CancellationException) throw error
                val result: OptionalResult<MuseumObject> = error.toAppError().left()
                emit(result)
            }
}

class InMemoryMuseumStorage : MuseumStorage {
    private val storedObjects = MutableStateFlow(emptyList<MuseumObject>())

    override suspend fun saveObjects(objects: List<MuseumObject>): AppResult<Unit> {
        storedObjects.value = objects
        return Unit.right()
    }

    override fun objects(): Flow<OptionalResult<List<MuseumObject>>> =
        storedObjects.map { objects ->
            val result: OptionalResult<List<MuseumObject>> =
                if (objects.isEmpty()) none<List<MuseumObject>>().right() else objects.some().right()
            result
        }

    override fun objectById(objectId: Int): Flow<OptionalResult<MuseumObject>> =
        storedObjects.map { objects ->
            val result: OptionalResult<MuseumObject> =
                objects.firstOrNull { it.objectID == objectId }.toOption().right()
            result
        }
}
