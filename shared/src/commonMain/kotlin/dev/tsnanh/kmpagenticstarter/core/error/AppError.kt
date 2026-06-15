package dev.tsnanh.kmpagenticstarter.core.error

data class AppError(
    val message: String,
    val code: String? = null,
    val cause: Throwable? = null,
)

fun Throwable.toAppError(code: String? = null): AppError =
    AppError(message = message ?: "Unexpected error", code = code, cause = this)
