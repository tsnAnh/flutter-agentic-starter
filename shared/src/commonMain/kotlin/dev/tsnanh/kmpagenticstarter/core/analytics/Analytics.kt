package dev.tsnanh.kmpagenticstarter.core.analytics

import arrow.optics.optics

@optics
data class AnalyticsEvent(
    val name: String,
    val properties: Map<String, String> = emptyMap(),
) {
    companion object
}

interface AnalyticsProvider {
    fun track(event: AnalyticsEvent)
    fun identify(userId: String, properties: Map<String, String> = emptyMap())
    fun reset()
}

class NoopAnalyticsProvider : AnalyticsProvider {
    override fun track(event: AnalyticsEvent) = Unit
    override fun identify(userId: String, properties: Map<String, String>) = Unit
    override fun reset() = Unit
}

class CompositeAnalyticsProvider(private val providers: List<AnalyticsProvider>) : AnalyticsProvider {
    override fun track(event: AnalyticsEvent) = providers.forEach { it.track(event) }
    override fun identify(userId: String, properties: Map<String, String>) =
        providers.forEach { it.identify(userId, properties) }

    override fun reset() = providers.forEach { it.reset() }
}
