package dev.tsnanh.kmpagenticstarter.core.firebase

interface FirebaseInitializer {
    suspend fun initialize()
}

interface CrashReporter {
    fun record(error: Throwable)
}

interface RemoteConfigService {
    fun getBoolean(key: String, defaultValue: Boolean = false): Boolean
    fun getString(key: String, defaultValue: String = ""): String
}

interface PushNotificationService {
    suspend fun token(): String?
}

class NoopFirebaseInitializer : FirebaseInitializer {
    override suspend fun initialize() = Unit
}

class NoopCrashReporter : CrashReporter {
    override fun record(error: Throwable) = Unit
}

class NoopRemoteConfigService : RemoteConfigService {
    override fun getBoolean(key: String, defaultValue: Boolean) = defaultValue
    override fun getString(key: String, defaultValue: String) = defaultValue
}

class NoopPushNotificationService : PushNotificationService {
    override suspend fun token(): String? = null
}
