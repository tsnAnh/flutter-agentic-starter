package dev.tsnanh.creativenote.core.database

import kotlinx.coroutines.Dispatchers
import kotlin.coroutines.CoroutineContext

// ponytail: Native has no public Dispatchers.IO here; Default is the portable Room context.
actual val databaseCoroutineContext: CoroutineContext = Dispatchers.Default
