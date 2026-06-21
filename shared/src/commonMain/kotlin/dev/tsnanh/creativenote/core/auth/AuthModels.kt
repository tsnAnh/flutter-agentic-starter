package dev.tsnanh.creativenote.core.auth

import arrow.core.Option
import arrow.core.none
import arrow.optics.optics

@optics
data class TokenSet(
    val accessToken: String,
    val refreshToken: Option<String> = none(),
) {
    companion object
}

@optics
data class Session(
    val userId: String,
    val isAuthenticated: Boolean,
) {
    companion object
}
