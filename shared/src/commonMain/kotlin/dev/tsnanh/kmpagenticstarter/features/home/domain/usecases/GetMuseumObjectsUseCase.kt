package dev.tsnanh.kmpagenticstarter.features.home.domain.usecases

import dev.tsnanh.kmpagenticstarter.core.base.AppResult
import dev.tsnanh.kmpagenticstarter.core.base.AsyncResult
import dev.tsnanh.kmpagenticstarter.core.base.NoInputUseCase
import dev.tsnanh.kmpagenticstarter.core.base.OptionalResult
import dev.tsnanh.kmpagenticstarter.features.home.domain.models.MuseumObject
import dev.tsnanh.kmpagenticstarter.features.home.domain.repositories.MuseumRepository
import kotlinx.coroutines.flow.Flow

class GetMuseumObjectsUseCase(private val repository: MuseumRepository) :
    NoInputUseCase<List<MuseumObject>> {
    override suspend fun invoke(): AppResult<List<MuseumObject>> = repository.refresh()
}

class ObserveMuseumObjectsUseCase(private val repository: MuseumRepository) {
    operator fun invoke(): Flow<AsyncResult<List<MuseumObject>>> = repository.objects()
}

class ObserveMuseumObjectUseCase(private val repository: MuseumRepository) {
    operator fun invoke(objectId: Int): Flow<OptionalResult<MuseumObject>> =
        repository.objectById(objectId)
}
