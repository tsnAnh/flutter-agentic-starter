package dev.tsnanh.kmpagenticstarter.core.auth

data class TokenSet(
    val accessToken: String,
    val refreshToken: String? = null,
)

data class Session(
    val userId: String,
    val isAuthenticated: Boolean,
)
