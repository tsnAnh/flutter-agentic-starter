package dev.tsnanh.kmpagenticstarter.di

import android.content.Context
import dev.tsnanh.kmpagenticstarter.core.config.AppConfig
import dev.tsnanh.kmpagenticstarter.core.database.getDatabaseBuilder
import org.koin.core.module.Module

fun initKoin(
    context: Context,
    config: AppConfig = AppConfig(),
    extraModules: List<Module> = emptyList(),
) {
    initKoin(config, getDatabaseBuilder(context), extraModules)
}
