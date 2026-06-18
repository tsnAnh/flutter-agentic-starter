package dev.tsnanh.kmpagenticstarter.core.database

import androidx.room.ConstructedBy
import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.RoomDatabaseConstructor
import androidx.sqlite.driver.bundled.BundledSQLiteDriver
import dev.tsnanh.kmpagenticstarter.features.home.data.datasources.MuseumObjectDao
import dev.tsnanh.kmpagenticstarter.features.home.data.datasources.MuseumObjectEntity
import kotlin.coroutines.CoroutineContext

internal const val DATABASE_NAME = "kmp-agentic-starter.db"

expect fun getDatabaseBuilder(): RoomDatabase.Builder<AppDatabase>

expect val databaseCoroutineContext: CoroutineContext

@Database(entities = [MuseumObjectEntity::class], version = 1)
@ConstructedBy(AppDatabaseConstructor::class)
abstract class AppDatabase : RoomDatabase() {
    abstract fun museumObjectDao(): MuseumObjectDao
}

@Suppress("KotlinNoActualForExpect")
expect object AppDatabaseConstructor : RoomDatabaseConstructor<AppDatabase> {
    override fun initialize(): AppDatabase
}

fun getRoomDatabase(builder: RoomDatabase.Builder<AppDatabase>): AppDatabase =
    builder
        .setDriver(BundledSQLiteDriver())
        .setQueryCoroutineContext(databaseCoroutineContext)
        .build()
