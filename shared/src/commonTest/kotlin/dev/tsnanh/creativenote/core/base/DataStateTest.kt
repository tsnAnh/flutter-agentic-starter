package dev.tsnanh.creativenote.core.base

import arrow.core.Either
import arrow.core.None
import arrow.core.Some
import arrow.core.right
import dev.tsnanh.creativenote.core.auth.InMemoryTokenStore
import dev.tsnanh.creativenote.core.auth.TokenSet
import dev.tsnanh.creativenote.core.cache.CacheManager
import dev.tsnanh.creativenote.core.forms.Validators
import dev.tsnanh.creativenote.core.offline.OfflineQueueService
import dev.tsnanh.creativenote.core.offline.QueuedRequest
import dev.tsnanh.creativenote.core.router.DeepLinkParser
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.test.runTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class AppResultTest {
    @Test
    fun appResultExposesRightValue() {
        val state: AppResult<String> = "ready".right()

        assertTrue(state is Either.Right)
        assertEquals("ready", state.value)
    }

    @Test
    fun validatorsAccumulateErrors() {
        val state = Validators.all(
            Validators.required(""),
            Validators.email("not-an-email"),
        )

        assertTrue(state is Either.Left)
        assertEquals(listOf("Required", "Invalid email"), state.value.toList())
    }

    @Test
    fun optionReturningHelpersUseSomeAndNone() {
        val cache = CacheManager()
        cache.set("name", "starter")

        assertTrue(cache.get<String>("name") is Some)
        assertEquals(None, cache.get<String>("missing"))
        assertTrue(DeepLinkParser().parse("app://host/detail/42") is Some)
        assertEquals(None, DeepLinkParser().parse("app://"))
    }

    @Test
    fun tokenStoreUsesOption() {
        val store = InMemoryTokenStore()

        assertEquals(None, store.read())
        store.write(TokenSet(accessToken = "access"))

        assertTrue(store.read() is Some)
    }

    @Test
    fun offlineQueueUpdatesAtomically() = runTest {
        val service = OfflineQueueService()

        (0 until 100)
            .map { id ->
                async(Dispatchers.Default) {
                    service.enqueue(QueuedRequest(id = "$id", method = "GET", url = "/$id"))
                }
            }
            .awaitAll()

        assertEquals(100, service.requests.value.size)

        (0 until 50)
            .map { id -> async(Dispatchers.Default) { service.remove("$id") } }
            .awaitAll()

        assertEquals(50, service.requests.value.size)
    }
}
