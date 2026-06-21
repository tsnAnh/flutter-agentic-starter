package dev.tsnanh.creativenote.di

import androidx.room.RoomDatabase
import dev.tsnanh.creativenote.core.analytics.AnalyticsProvider
import dev.tsnanh.creativenote.core.analytics.NoopAnalyticsProvider
import dev.tsnanh.creativenote.core.auth.InMemoryTokenStore
import dev.tsnanh.creativenote.core.auth.SecureTokenStore
import dev.tsnanh.creativenote.core.auth.SessionManager
import dev.tsnanh.creativenote.core.auth.TokenManager
import dev.tsnanh.creativenote.core.cache.CacheManager
import dev.tsnanh.creativenote.core.config.AppConfig
import dev.tsnanh.creativenote.core.connectivity.ConnectivityMonitor
import dev.tsnanh.creativenote.core.connectivity.DefaultConnectivityMonitor
import dev.tsnanh.creativenote.core.database.AppDatabase
import dev.tsnanh.creativenote.core.database.getDatabaseBuilder
import dev.tsnanh.creativenote.core.database.getRoomDatabase
import dev.tsnanh.creativenote.core.firebase.CrashReporter
import dev.tsnanh.creativenote.core.firebase.FirebaseInitializer
import dev.tsnanh.creativenote.core.firebase.NoopCrashReporter
import dev.tsnanh.creativenote.core.firebase.NoopFirebaseInitializer
import dev.tsnanh.creativenote.core.firebase.NoopPushNotificationService
import dev.tsnanh.creativenote.core.firebase.NoopRemoteConfigService
import dev.tsnanh.creativenote.core.firebase.PushNotificationService
import dev.tsnanh.creativenote.core.firebase.RemoteConfigService
import dev.tsnanh.creativenote.core.lifecycle.AppLifecycleMonitor
import dev.tsnanh.creativenote.core.logger.AppLogger
import dev.tsnanh.creativenote.core.logger.KermitAppLogger
import dev.tsnanh.creativenote.core.network.KtorHttpClientFactory
import dev.tsnanh.creativenote.core.offline.OfflineQueueService
import dev.tsnanh.creativenote.core.permissions.DefaultPermissionService
import dev.tsnanh.creativenote.core.permissions.PermissionService
import dev.tsnanh.creativenote.core.router.DeepLinkParser
import dev.tsnanh.creativenote.features.notes.data.datasources.RoomVoiceNoteStorage
import dev.tsnanh.creativenote.features.notes.data.datasources.VoiceNoteStorage
import dev.tsnanh.creativenote.features.notes.data.repositories.DefaultNoteRepository
import dev.tsnanh.creativenote.features.notes.domain.repositories.NoteRepository
import dev.tsnanh.creativenote.features.notes.domain.usecases.ObserveVoiceNotesUseCase
import dev.tsnanh.creativenote.features.notes.domain.usecases.SaveVoiceNoteUseCase
import dev.tsnanh.creativenote.features.notes.presentation.NotesViewModel
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
    single { get<AppDatabase>().voiceNoteDao() }
}

val notesModule = module {
    single<VoiceNoteStorage> { RoomVoiceNoteStorage(get()) }
    single<NoteRepository> { DefaultNoteRepository(get()) }
    factory { ObserveVoiceNotesUseCase(get()) }
    factory { SaveVoiceNoteUseCase(get()) }
    factory { NotesViewModel(get(), get()) }
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
            notesModule,
            *extraModules.toTypedArray(),
        )
    }
}
