package dev.tsnanh.creativenote.core.lifecycle

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

enum class AppLifecycleState { Foreground, Background, Inactive }

class AppLifecycleMonitor {
    private val mutableState = MutableStateFlow(AppLifecycleState.Inactive)
    val state: StateFlow<AppLifecycleState> = mutableState

    fun update(state: AppLifecycleState) {
        mutableState.value = state
    }
}
