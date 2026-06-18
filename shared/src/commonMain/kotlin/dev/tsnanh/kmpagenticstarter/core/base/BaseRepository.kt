package dev.tsnanh.kmpagenticstarter.core.base

import arrow.core.left
import arrow.core.right
import dev.tsnanh.kmpagenticstarter.core.error.toAppError
import kotlin.coroutines.cancellation.CancellationException

abstract class BaseRepository {
    protected suspend fun <T> safeCall(block: suspend () -> T): AppResult<T> =
        try {
            block().right()
        } catch (error: CancellationException) {
            throw error
        } catch (error: Throwable) {
            error.toAppError().left()
        }
}
