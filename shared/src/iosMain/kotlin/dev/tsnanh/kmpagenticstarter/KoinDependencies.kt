package dev.tsnanh.kmpagenticstarter

import dev.tsnanh.kmpagenticstarter.features.home.domain.repositories.MuseumRepository
import org.koin.core.component.KoinComponent
import org.koin.core.component.inject

class KoinDependencies : KoinComponent {
    val museumRepository: MuseumRepository by inject()
}
