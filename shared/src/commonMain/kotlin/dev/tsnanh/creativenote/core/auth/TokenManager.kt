package dev.tsnanh.creativenote.core.auth

import arrow.core.Option
import arrow.core.none
import arrow.core.some
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

class TokenManager(private val tokenStore: SecureTokenStore) {
    private val mutableTokens = MutableStateFlow(tokenStore.read())
    val tokens: StateFlow<Option<TokenSet>> = mutableTokens

    fun currentAccessToken(): Option<String> = mutableTokens.value.map { it.accessToken }

    fun save(tokens: TokenSet) {
        tokenStore.write(tokens)
        mutableTokens.value = tokens.some()
    }

    fun clear() {
        tokenStore.clear()
        mutableTokens.value = none()
    }
}
