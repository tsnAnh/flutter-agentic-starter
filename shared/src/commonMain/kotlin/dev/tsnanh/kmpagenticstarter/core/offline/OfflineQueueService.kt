package dev.tsnanh.kmpagenticstarter.core.offline

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.serialization.Serializable

@Serializable
data class QueuedRequest(
    val id: String,
    val method: String,
    val url: String,
    val body: String? = null,
)

class OfflineQueueService {
    private val mutableRequests = MutableStateFlow(emptyList<QueuedRequest>())
    val requests: StateFlow<List<QueuedRequest>> = mutableRequests

    fun enqueue(request: QueuedRequest) {
        mutableRequests.value = mutableRequests.value + request
    }

    fun remove(id: String) {
        mutableRequests.value = mutableRequests.value.filterNot { it.id == id }
    }
}
