package dev.tsnanh.creativenote

import android.app.Application
import dev.tsnanh.creativenote.di.initKoin

class KmpAgenticStarterApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        initKoin(this)
    }
}
