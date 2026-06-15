package dev.tsnanh.kmpagenticstarter.core.utils

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class Debouncer(
    private val scope: CoroutineScope,
    private val delayMillis: Long,
) {
    private var job: Job? = null

    fun submit(block: suspend () -> Unit) {
        job?.cancel()
        job = scope.launch {
            delay(delayMillis)
            block()
        }
    }
}

class Throttler(private val intervalMillis: Long) {
    private var lastRunMillis = 0L

    fun run(nowMillis: Long, block: () -> Unit) {
        if (nowMillis - lastRunMillis >= intervalMillis) {
            lastRunMillis = nowMillis
            block()
        }
    }
}
