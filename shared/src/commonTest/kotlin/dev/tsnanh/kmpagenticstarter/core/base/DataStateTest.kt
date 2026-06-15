package dev.tsnanh.kmpagenticstarter.core.base

import kotlin.test.Test
import kotlin.test.assertEquals

class DataStateTest {
    @Test
    fun loadedStateExposesData() {
        val state: DataState<String> = DataState.Loaded("ready")

        assertEquals("ready", state.dataOrNull)
    }
}
