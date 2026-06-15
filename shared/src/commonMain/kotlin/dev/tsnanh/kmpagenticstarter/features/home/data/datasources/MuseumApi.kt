package dev.tsnanh.kmpagenticstarter.features.home.data.datasources

import dev.tsnanh.kmpagenticstarter.core.config.AppConfig
import dev.tsnanh.kmpagenticstarter.features.home.domain.models.MuseumObject
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.request.get

interface MuseumApi {
    suspend fun getObjects(): List<MuseumObject>
}

class KtorMuseumApi(
    private val client: HttpClient,
    private val config: AppConfig,
) : MuseumApi {
    override suspend fun getObjects(): List<MuseumObject> =
        client.get("${config.apiBaseUrl}/list.json").body()
}
