package dev.tsnanh.kmpagenticstarter

import dev.tsnanh.kmpagenticstarter.features.home.presentation.DetailViewModel
import dev.tsnanh.kmpagenticstarter.features.home.presentation.ListViewModel
import org.koin.core.component.KoinComponent
import org.koin.core.component.inject

class KoinDependencies : KoinComponent {
    val listViewModel: ListViewModel by inject()
    val detailViewModel: DetailViewModel by inject()
}
