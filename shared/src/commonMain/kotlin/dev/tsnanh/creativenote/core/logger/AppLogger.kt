package dev.tsnanh.creativenote.core.logger

import co.touchlab.kermit.Logger

interface AppLogger {
    fun debug(message: String)
    fun info(message: String)
    fun warn(message: String, throwable: Throwable? = null)
    fun error(message: String, throwable: Throwable? = null)
}

class KermitAppLogger(private val logger: Logger = Logger.withTag("KMPAgenticStarter")) : AppLogger {
    override fun debug(message: String) = logger.d { message }
    override fun info(message: String) = logger.i { message }
    override fun warn(message: String, throwable: Throwable?) = logger.w(throwable) { message }
    override fun error(message: String, throwable: Throwable?) = logger.e(throwable) { message }
}
