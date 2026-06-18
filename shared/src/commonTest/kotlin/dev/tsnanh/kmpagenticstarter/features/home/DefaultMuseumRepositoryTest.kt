package dev.tsnanh.kmpagenticstarter.features.home

import arrow.core.Either
import arrow.core.Some
import arrow.core.left
import arrow.core.right
import dev.tsnanh.kmpagenticstarter.core.error.AppError
import dev.tsnanh.kmpagenticstarter.features.home.data.datasources.InMemoryMuseumStorage
import dev.tsnanh.kmpagenticstarter.features.home.data.datasources.MuseumApi
import dev.tsnanh.kmpagenticstarter.features.home.data.datasources.MuseumObjectDto
import dev.tsnanh.kmpagenticstarter.features.home.data.repositories.DefaultMuseumRepository
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.runTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class DefaultMuseumRepositoryTest {
    @Test
    fun refreshStoresFetchedObjects() = runTest {
        val storage = InMemoryMuseumStorage()
        val repository = DefaultMuseumRepository(FakeMuseumApi, storage)

        val state = repository.refresh()

        assertTrue(state is Either.Right)
        assertEquals("Starter Object", state.value.first().title)

        val stored = storage.objects().first()
        assertTrue(stored is Either.Right)
        val storedObjects = stored.value
        assertTrue(storedObjects is Some)
        assertEquals("Starter Object", storedObjects.value.first().title)
    }

    @Test
    fun refreshReturnsTypedErrorWhenApiFails() = runTest {
        val repository = DefaultMuseumRepository(FailingMuseumApi, InMemoryMuseumStorage())

        val state = repository.refresh()

        assertTrue(state is Either.Left)
        assertEquals("Network failed", state.value.message)
    }

    private object FakeMuseumApi : MuseumApi {
        override suspend fun getObjects() = listOf(
            MuseumObjectDto(
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
        ).right()
    }

    private object FailingMuseumApi : MuseumApi {
        override suspend fun getObjects() = AppError("Network failed").left()
    }
}
