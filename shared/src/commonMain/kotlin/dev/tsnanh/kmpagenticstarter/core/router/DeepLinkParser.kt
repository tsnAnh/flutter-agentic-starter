package dev.tsnanh.kmpagenticstarter.core.router

data class AppRoute(val name: String, val arguments: Map<String, String> = emptyMap())

class DeepLinkParser {
    fun parse(url: String): AppRoute? {
        val path = url.substringAfter("://", url).substringAfter('/').trim('/')
        if (path.isBlank()) return null
        val parts = path.split('/')
        return when (parts.first()) {
            "home" -> AppRoute("home")
            "detail" -> parts.getOrNull(1)?.let { AppRoute("detail", mapOf("id" to it)) }
            else -> null
        }
    }
}
