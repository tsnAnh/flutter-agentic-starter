package dev.tsnanh.kmpagenticstarter.features.home.data.datasources

import arrow.resilience.Schedule
import arrow.resilience.retry
import dev.tsnanh.kmpagenticstarter.core.base.AppResult
import dev.tsnanh.kmpagenticstarter.core.base.BaseRepository
import dev.tsnanh.kmpagenticstarter.core.config.AppConfig
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.request.get
import kotlinx.io.IOException

interface MuseumApi {
    suspend fun getObjects(): AppResult<List<MuseumObjectDto>>
}

class KtorMuseumApi(
    private val client: HttpClient,
    private val config: AppConfig,
) : BaseRepository(), MuseumApi {
    override suspend fun getObjects(): AppResult<List<MuseumObjectDto>> =
        safeCall {
            Schedule.recurs<IOException>(2).retry {
                client.get("${config.apiBaseUrl}/list.json").body()
            }
        }
}
