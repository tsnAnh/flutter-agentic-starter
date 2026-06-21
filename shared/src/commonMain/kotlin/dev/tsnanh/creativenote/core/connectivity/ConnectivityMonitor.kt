package dev.tsnanh.creativenote.core.connectivity

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

enum class ConnectivityStatus { Online, Offline, Unknown }

interface ConnectivityMonitor {
    val status: StateFlow<ConnectivityStatus>
}

class DefaultConnectivityMonitor : ConnectivityMonitor {
    override val status = MutableStateFlow(ConnectivityStatus.Unknown)
}
