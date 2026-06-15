package dev.tsnanh.kmpagenticstarter.core.auth

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

class TokenManager(private val tokenStore: SecureTokenStore) {
    private val mutableTokens = MutableStateFlow(tokenStore.read())
    val tokens: StateFlow<TokenSet?> = mutableTokens

    fun currentAccessToken(): String? = mutableTokens.value?.accessToken

    fun save(tokens: TokenSet) {
        tokenStore.write(tokens)
        mutableTokens.value = tokens
    }

    fun clear() {
        tokenStore.clear()
        mutableTokens.value = null
    }
}
