package dev.tsnanh.kmpagenticstarter.core.base

import dev.tsnanh.kmpagenticstarter.core.error.toAppError
import kotlin.coroutines.cancellation.CancellationException

abstract class BaseRepository {
    protected suspend fun <T> safeCall(block: suspend () -> T): DataState<T> =
        try {
            DataState.Loaded(block())
        } catch (error: CancellationException) {
            throw error
        } catch (error: Throwable) {
            DataState.Error(error.toAppError())
        }
}
