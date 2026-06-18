package dev.tsnanh.kmpagenticstarter.core.database

import kotlinx.coroutines.Dispatchers
import kotlin.coroutines.CoroutineContext

actual val databaseCoroutineContext: CoroutineContext = Dispatchers.IO
