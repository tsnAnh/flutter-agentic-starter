package dev.tsnanh.creativenote.core.database

import kotlinx.coroutines.Dispatchers
import kotlin.coroutines.CoroutineContext

actual val databaseCoroutineContext: CoroutineContext = Dispatchers.IO
