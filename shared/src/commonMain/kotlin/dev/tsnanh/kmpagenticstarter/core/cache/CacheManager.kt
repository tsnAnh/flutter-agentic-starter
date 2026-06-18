package dev.tsnanh.kmpagenticstarter.core.cache

import arrow.core.Option
import arrow.core.none
import arrow.core.toOption
import kotlin.time.Duration
import kotlin.time.Duration.Companion.minutes
import kotlin.time.TimeSource

data class CachePolicy(val ttl: Duration = 30.minutes) {
    companion object {
        val Short = CachePolicy(5.minutes)
        val Default = CachePolicy()
    }
}

private data class CacheEntry<T>(
    val value: T,
    val expiresAt: TimeSource.Monotonic.ValueTimeMark,
)

class CacheManager {
    private val entries = mutableMapOf<String, CacheEntry<Any>>()

    fun <T : Any> set(key: String, value: T, policy: CachePolicy = CachePolicy.Default) {
        entries[key] = CacheEntry(value, TimeSource.Monotonic.markNow() + policy.ttl)
    }

    @Suppress("UNCHECKED_CAST")
    fun <T : Any> get(key: String): Option<T> {
        val entry = entries[key] ?: return none()
        if (entry.expiresAt.hasPassedNow()) {
            entries.remove(key)
            return none()
        }
        return (entry.value as? T).toOption()
    }

    fun invalidate(key: String) {
        entries.remove(key)
    }

    fun clear() {
        entries.clear()
    }
}
