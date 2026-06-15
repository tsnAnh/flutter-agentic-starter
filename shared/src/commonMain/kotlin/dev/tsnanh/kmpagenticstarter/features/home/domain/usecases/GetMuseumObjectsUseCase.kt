package dev.tsnanh.kmpagenticstarter.features.home.domain.usecases

import dev.tsnanh.kmpagenticstarter.core.base.DataState
import dev.tsnanh.kmpagenticstarter.core.base.NoInputUseCase
import dev.tsnanh.kmpagenticstarter.features.home.domain.models.MuseumObject
import dev.tsnanh.kmpagenticstarter.features.home.domain.repositories.MuseumRepository

class GetMuseumObjectsUseCase(private val repository: MuseumRepository) :
    NoInputUseCase<List<MuseumObject>> {
    override suspend fun invoke(): DataState<List<MuseumObject>> = repository.refresh()
}
