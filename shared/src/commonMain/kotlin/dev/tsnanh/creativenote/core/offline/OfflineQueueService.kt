package dev.tsnanh.creativenote.core.offline

import arrow.optics.optics
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.update
import kotlinx.serialization.Serializable

@optics
@Serializable
data class QueuedRequest(
    val id: String,
    val method: String,
    val url: String,
    val body: String? = null,
) {
    companion object
}

class OfflineQueueService {
    private val mutableRequests = MutableStateFlow(emptyList<QueuedRequest>())
    val requests: StateFlow<List<QueuedRequest>> = mutableRequests

    fun enqueue(request: QueuedRequest) {
        mutableRequests.update { it + request }
    }

    fun remove(id: String) {
        mutableRequests.update { requests -> requests.filterNot { it.id == id } }
    }
}
