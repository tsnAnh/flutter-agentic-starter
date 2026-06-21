package dev.tsnanh.creativenote.core.error

import arrow.optics.optics

@optics
data class AppError(
    val message: String,
    val code: String? = null,
    val cause: Throwable? = null,
) {
    companion object
}

fun Throwable.toAppError(code: String? = null): AppError =
    AppError(message = message ?: "Unexpected error", code = code, cause = this)
