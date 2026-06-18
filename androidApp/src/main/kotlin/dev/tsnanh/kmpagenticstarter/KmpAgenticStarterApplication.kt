package dev.tsnanh.kmpagenticstarter

import android.app.Application
import dev.tsnanh.kmpagenticstarter.di.initKoin

class KmpAgenticStarterApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        initKoin(this)
    }
}
