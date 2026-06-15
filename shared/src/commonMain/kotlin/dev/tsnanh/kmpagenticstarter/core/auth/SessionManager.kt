package dev.tsnanh.kmpagenticstarter.core.auth

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

class SessionManager(private val tokenManager: TokenManager) {
    private val mutableSession = MutableStateFlow(Session(userId = "", isAuthenticated = false))
    val session: StateFlow<Session> = mutableSession

    fun signIn(userId: String, tokens: TokenSet) {
        tokenManager.save(tokens)
        mutableSession.value = Session(userId = userId, isAuthenticated = true)
    }

    fun signOut() {
        tokenManager.clear()
        mutableSession.value = Session(userId = "", isAuthenticated = false)
    }
}
