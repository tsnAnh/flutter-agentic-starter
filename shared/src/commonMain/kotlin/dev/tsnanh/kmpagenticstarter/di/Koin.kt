package dev.tsnanh.kmpagenticstarter.di

import androidx.room.RoomDatabase
import dev.tsnanh.kmpagenticstarter.core.analytics.AnalyticsProvider
import dev.tsnanh.kmpagenticstarter.core.analytics.NoopAnalyticsProvider
import dev.tsnanh.kmpagenticstarter.core.auth.InMemoryTokenStore
import dev.tsnanh.kmpagenticstarter.core.auth.SecureTokenStore
import dev.tsnanh.kmpagenticstarter.core.auth.SessionManager
import dev.tsnanh.kmpagenticstarter.core.auth.TokenManager
import dev.tsnanh.kmpagenticstarter.core.cache.CacheManager
import dev.tsnanh.kmpagenticstarter.core.config.AppConfig
import dev.tsnanh.kmpagenticstarter.core.connectivity.ConnectivityMonitor
import dev.tsnanh.kmpagenticstarter.core.connectivity.DefaultConnectivityMonitor
import dev.tsnanh.kmpagenticstarter.core.database.AppDatabase
import dev.tsnanh.kmpagenticstarter.core.database.getDatabaseBuilder
import dev.tsnanh.kmpagenticstarter.core.database.getRoomDatabase
import dev.tsnanh.kmpagenticstarter.core.firebase.CrashReporter
import dev.tsnanh.kmpagenticstarter.core.firebase.FirebaseInitializer
import dev.tsnanh.kmpagenticstarter.core.firebase.NoopCrashReporter
import dev.tsnanh.kmpagenticstarter.core.firebase.NoopFirebaseInitializer
import dev.tsnanh.kmpagenticstarter.core.firebase.NoopPushNotificationService
import dev.tsnanh.kmpagenticstarter.core.firebase.NoopRemoteConfigService
import dev.tsnanh.kmpagenticstarter.core.firebase.PushNotificationService
import dev.tsnanh.kmpagenticstarter.core.firebase.RemoteConfigService
import dev.tsnanh.kmpagenticstarter.core.lifecycle.AppLifecycleMonitor
import dev.tsnanh.kmpagenticstarter.core.logger.AppLogger
import dev.tsnanh.kmpagenticstarter.core.logger.KermitAppLogger
import dev.tsnanh.kmpagenticstarter.core.network.KtorHttpClientFactory
import dev.tsnanh.kmpagenticstarter.core.offline.OfflineQueueService
import dev.tsnanh.kmpagenticstarter.core.permissions.DefaultPermissionService
import dev.tsnanh.kmpagenticstarter.core.permissions.PermissionService
import dev.tsnanh.kmpagenticstarter.core.router.DeepLinkParser
import dev.tsnanh.kmpagenticstarter.features.home.data.datasources.KtorMuseumApi
import dev.tsnanh.kmpagenticstarter.features.home.data.datasources.MuseumApi
import dev.tsnanh.kmpagenticstarter.features.home.data.datasources.MuseumStorage
import dev.tsnanh.kmpagenticstarter.features.home.data.datasources.RoomMuseumStorage
import dev.tsnanh.kmpagenticstarter.features.home.data.repositories.DefaultMuseumRepository
import dev.tsnanh.kmpagenticstarter.features.home.domain.repositories.MuseumRepository
import dev.tsnanh.kmpagenticstarter.features.home.domain.usecases.GetMuseumObjectsUseCase
import dev.tsnanh.kmpagenticstarter.features.home.domain.usecases.ObserveMuseumObjectUseCase
import dev.tsnanh.kmpagenticstarter.features.home.domain.usecases.ObserveMuseumObjectsUseCase
import dev.tsnanh.kmpagenticstarter.features.home.presentation.DetailViewModel
import dev.tsnanh.kmpagenticstarter.features.home.presentation.ListViewModel
import org.koin.core.context.startKoin
import org.koin.core.module.Module
import org.koin.dsl.module

fun coreModule(config: AppConfig) = module {
    single { config }
    single<AppLogger> { KermitAppLogger() }
    single<SecureTokenStore> { InMemoryTokenStore() }
    single { TokenManager(get()) }
    single { SessionManager(get()) }
    single { CacheManager() }
    single<ConnectivityMonitor> { DefaultConnectivityMonitor() }
    single { OfflineQueueService() }
    single<AnalyticsProvider> { NoopAnalyticsProvider() }
    single<FirebaseInitializer> { NoopFirebaseInitializer() }
    single<CrashReporter> { NoopCrashReporter() }
    single<RemoteConfigService> { NoopRemoteConfigService() }
    single<PushNotificationService> { NoopPushNotificationService() }
    single<PermissionService> { DefaultPermissionService() }
    single { AppLifecycleMonitor() }
    single { DeepLinkParser() }
    single { KtorHttpClientFactory(get(), get()).create() }
}

fun databaseModule(databaseBuilder: RoomDatabase.Builder<AppDatabase>) = module {
    single { getRoomDatabase(databaseBuilder) }
    single { get<AppDatabase>().museumObjectDao() }
}

val homeModule = module {
    single<MuseumApi> { KtorMuseumApi(get(), get()) }
    single<MuseumStorage> { RoomMuseumStorage(get()) }
    single<MuseumRepository> { DefaultMuseumRepository(get(), get()) }
    factory { GetMuseumObjectsUseCase(get()) }
    factory { ObserveMuseumObjectsUseCase(get()) }
    factory { ObserveMuseumObjectUseCase(get()) }
    factory { ListViewModel(get(), get()) }
    factory { DetailViewModel(get()) }
}

fun initKoin() = initKoin(AppConfig(), getDatabaseBuilder(), emptyList())

fun initKoin(config: AppConfig = AppConfig(), extraModules: List<Module> = emptyList()) {
    initKoin(config, getDatabaseBuilder(), extraModules)
}

fun initKoin(
    config: AppConfig,
    databaseBuilder: RoomDatabase.Builder<AppDatabase>,
    extraModules: List<Module> = emptyList(),
) {
    startKoin {
        modules(
            coreModule(config),
            databaseModule(databaseBuilder),
            homeModule,
            *extraModules.toTypedArray(),
        )
    }
}
