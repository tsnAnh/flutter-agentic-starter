package dev.tsnanh.kmpagenticstarter.features.home

import dev.tsnanh.kmpagenticstarter.core.base.DataState
import dev.tsnanh.kmpagenticstarter.features.home.data.datasources.InMemoryMuseumStorage
import dev.tsnanh.kmpagenticstarter.features.home.data.datasources.MuseumApi
import dev.tsnanh.kmpagenticstarter.features.home.data.repositories.DefaultMuseumRepository
import dev.tsnanh.kmpagenticstarter.features.home.domain.models.MuseumObject
import kotlinx.coroutines.test.runTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class DefaultMuseumRepositoryTest {
    @Test
    fun refreshStoresFetchedObjects() = runTest {
        val repository = DefaultMuseumRepository(FakeMuseumApi, InMemoryMuseumStorage())

        val state = repository.refresh()

        assertTrue(state is DataState.Loaded)
        assertEquals("Starter Object", state.data.first().title)
    }

    private object FakeMuseumApi : MuseumApi {
        override suspend fun getObjects(): List<MuseumObject> = listOf(
            MuseumObject(
                objectID = 1,
                title = "Starter Object",
                artistDisplayName = "AnyFoundry",
                medium = "Kotlin",
                dimensions = "1 file",
                objectURL = "https://example.com",
                objectDate = "2026",
                primaryImage = "https://example.com/full.png",
                primaryImageSmall = "https://example.com/small.png",
                repository = "KMP Agentic Starter",
                department = "Architecture",
                creditLine = "Template",
            )
        )
    }
}
