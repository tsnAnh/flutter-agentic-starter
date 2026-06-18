package dev.tsnanh.kmpagenticstarter.features.home.data.repositories

import arrow.core.left
import arrow.core.right
import arrow.core.some
import arrow.core.raise.either
import dev.tsnanh.kmpagenticstarter.core.base.AppResult
import dev.tsnanh.kmpagenticstarter.core.base.AsyncResult
import dev.tsnanh.kmpagenticstarter.core.base.OptionalResult
import dev.tsnanh.kmpagenticstarter.features.home.data.toDomain
import dev.tsnanh.kmpagenticstarter.features.home.data.datasources.MuseumApi
import dev.tsnanh.kmpagenticstarter.features.home.data.datasources.MuseumStorage
import dev.tsnanh.kmpagenticstarter.features.home.domain.models.MuseumObject
import dev.tsnanh.kmpagenticstarter.features.home.domain.repositories.MuseumRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class DefaultMuseumRepository(
    private val api: MuseumApi,
    private val storage: MuseumStorage,
) : MuseumRepository {
    override suspend fun refresh(): AppResult<List<MuseumObject>> = either {
        val objects = api.getObjects().bind().map { it.toDomain() }
        storage.saveObjects(objects).bind()
        objects
    }

    override fun objects(): Flow<AsyncResult<List<MuseumObject>>> =
        storage.objects().map { it.toAsyncResult() }

    override fun objectById(objectId: Int): Flow<OptionalResult<MuseumObject>> =
        storage.objectById(objectId)
}

private fun <T> OptionalResult<T>.toAsyncResult(): AsyncResult<T> =
    fold(
        ifLeft = { it.left().some() },
        ifRight = { option -> option.map { it.right() } },
    )
