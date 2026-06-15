package dev.tsnanh.kmpagenticstarter.core.auth

import com.russhwolf.settings.Settings

interface SecureTokenStore {
    fun read(): TokenSet?
    fun write(tokens: TokenSet)
    fun clear()
}

class SettingsTokenStore(private val settings: Settings) : SecureTokenStore {
    override fun read(): TokenSet? {
        val access = settings.getStringOrNull(accessKey) ?: return null
        return TokenSet(accessToken = access, refreshToken = settings.getStringOrNull(refreshKey))
    }

    override fun write(tokens: TokenSet) {
        settings.putString(accessKey, tokens.accessToken)
        tokens.refreshToken?.let { settings.putString(refreshKey, it) } ?: settings.remove(refreshKey)
    }

    override fun clear() {
        settings.remove(accessKey)
        settings.remove(refreshKey)
    }

    private companion object {
        const val accessKey = "auth.access_token"
        const val refreshKey = "auth.refresh_token"
    }
}

class InMemoryTokenStore : SecureTokenStore {
    private var tokens: TokenSet? = null

    override fun read(): TokenSet? = tokens

    override fun write(tokens: TokenSet) {
        this.tokens = tokens
    }

    override fun clear() {
        tokens = null
    }
}
