package dev.tsnanh.kmpagenticstarter.core.auth

import arrow.core.Option
import arrow.core.none
import arrow.core.some
import arrow.core.toOption
import com.russhwolf.settings.Settings

interface SecureTokenStore {
    fun read(): Option<TokenSet>
    fun write(tokens: TokenSet)
    fun clear()
}

class SettingsTokenStore(private val settings: Settings) : SecureTokenStore {
    override fun read(): Option<TokenSet> {
        val access = settings.getStringOrNull(accessKey) ?: return none()
        return TokenSet(
            accessToken = access,
            refreshToken = settings.getStringOrNull(refreshKey).toOption(),
        ).some()
    }

    override fun write(tokens: TokenSet) {
        settings.putString(accessKey, tokens.accessToken)
        tokens.refreshToken.fold(
            ifEmpty = { settings.remove(refreshKey) },
            ifSome = { settings.putString(refreshKey, it) },
        )
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
    private var tokens: Option<TokenSet> = none()

    override fun read(): Option<TokenSet> = tokens

    override fun write(tokens: TokenSet) {
        this.tokens = tokens.some()
    }

    override fun clear() {
        tokens = none()
    }
}
