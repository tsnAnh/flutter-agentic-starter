package dev.tsnanh.kmpagenticstarter.core.database

import android.content.Context
import androidx.room.Room
import androidx.room.RoomDatabase

actual fun getDatabaseBuilder(): RoomDatabase.Builder<AppDatabase> =
    error("Android Room setup needs Context. Call initKoin(context).")

fun getDatabaseBuilder(context: Context): RoomDatabase.Builder<AppDatabase> {
    val appContext = context.applicationContext
    val dbFile = appContext.getDatabasePath(DATABASE_NAME)
    return Room.databaseBuilder<AppDatabase>(
        context = appContext,
        name = dbFile.absolutePath,
    )
}
