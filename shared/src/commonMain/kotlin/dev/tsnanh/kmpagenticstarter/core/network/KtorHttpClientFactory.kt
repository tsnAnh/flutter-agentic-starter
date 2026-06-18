package dev.tsnanh.kmpagenticstarter.core.network

import dev.tsnanh.kmpagenticstarter.core.auth.TokenManager
import dev.tsnanh.kmpagenticstarter.core.config.AppConfig
import io.ktor.client.HttpClient
import io.ktor.client.plugins.HttpTimeout
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.plugins.defaultRequest
import io.ktor.client.plugins.logging.DEFAULT
import io.ktor.client.plugins.logging.LogLevel
import io.ktor.client.plugins.logging.Logger
import io.ktor.client.plugins.logging.Logging
import io.ktor.client.request.bearerAuth
import io.ktor.http.ContentType
import io.ktor.http.contentType
import io.ktor.serialization.kotlinx.json.json
import kotlinx.serialization.json.Json

class KtorHttpClientFactory(
    private val config: AppConfig,
    private val tokenManager: TokenManager,
) {
    fun create(): HttpClient = HttpClient {
        install(ContentNegotiation) {
            json(Json { ignoreUnknownKeys = true }, contentType = ContentType.Any)
        }
        install(HttpTimeout) {
            requestTimeoutMillis = config.requestTimeoutMillis
            connectTimeoutMillis = config.requestTimeoutMillis
            socketTimeoutMillis = config.requestTimeoutMillis
        }
        install(Logging) {
            logger = Logger.DEFAULT
            level = LogLevel.INFO
        }
        defaultRequest {
            contentType(ContentType.Application.Json)
            tokenManager.currentAccessToken().fold(
                ifEmpty = {},
                ifSome = { bearerAuth(it) },
            )
        }
    }
}
