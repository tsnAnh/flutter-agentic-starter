package dev.tsnanh.creativenote.core.config

import arrow.optics.optics

enum class Flavor { Development, Staging, Production }

@optics
data class AppConfig(
    val appName: String = "Creative Note",
    val flavor: Flavor = Flavor.Development,
    val apiBaseUrl: String = "https://raw.githubusercontent.com/Kotlin/KMP-App-Template-Native/main",
    val requestTimeoutMillis: Long = 30_000,
    val posthogApiKey: String? = null,
    val posthogHost: String = "https://app.posthog.com",
) {
    companion object
}
