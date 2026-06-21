package dev.tsnanh.creativenote.core.router

import arrow.core.Option
import arrow.core.none
import arrow.core.some
import arrow.core.toOption
import arrow.optics.optics

@optics
data class AppRoute(val name: String, val arguments: Map<String, String> = emptyMap()) {
    companion object
}

class DeepLinkParser {
    fun parse(url: String): Option<AppRoute> {
        val path = url.substringAfter("://", url).substringAfter('/').trim('/')
        if (path.isBlank()) return none()
        val parts = path.split('/')
        return when (parts.first()) {
            "home" -> AppRoute("home").some()
            "detail" -> parts.getOrNull(1)?.let { AppRoute("detail", mapOf("id" to it)) }.toOption()
            else -> none()
        }
    }
}
