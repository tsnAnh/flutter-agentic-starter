package dev.tsnanh.kmpagenticstarter

import android.app.Application
import dev.tsnanh.kmpagenticstarter.di.initKoin
import dev.tsnanh.kmpagenticstarter.features.home.presentation.DetailViewModel
import dev.tsnanh.kmpagenticstarter.features.home.presentation.ListViewModel
import org.koin.dsl.module

class KmpAgenticStarterApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        initKoin(
            extraModules = listOf(
                module {
                    factory { ListViewModel(get()) }
                    factory { DetailViewModel(get()) }
                }
            )
        )
    }
}
