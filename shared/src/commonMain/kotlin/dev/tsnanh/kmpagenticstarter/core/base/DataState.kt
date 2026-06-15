package dev.tsnanh.kmpagenticstarter.core.base

import dev.tsnanh.kmpagenticstarter.core.error.AppError

sealed interface DataState<out T> {
    data object Initial : DataState<Nothing>
    data object Loading : DataState<Nothing>
    data class Loaded<T>(val data: T) : DataState<T>
    data class Error(val error: AppError) : DataState<Nothing>
}

val <T> DataState<T>.dataOrNull: T?
    get() = (this as? DataState.Loaded<T>)?.data
