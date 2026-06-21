package dev.tsnanh.creativenote.core.database

import androidx.room.ConstructedBy
import androidx.room.Database
import androidx.room.migration.Migration
import androidx.room.RoomDatabase
import androidx.room.RoomDatabaseConstructor
import androidx.sqlite.driver.bundled.BundledSQLiteDriver
import androidx.sqlite.SQLiteConnection
import androidx.sqlite.execSQL
import dev.tsnanh.creativenote.features.notes.data.datasources.VoiceNoteDao
import dev.tsnanh.creativenote.features.notes.data.datasources.VoiceNoteEntity
import kotlin.coroutines.CoroutineContext

internal const val DATABASE_NAME = "creative-note.db"

expect fun getDatabaseBuilder(): RoomDatabase.Builder<AppDatabase>

expect val databaseCoroutineContext: CoroutineContext

@Database(entities = [VoiceNoteEntity::class], version = 3)
@ConstructedBy(AppDatabaseConstructor::class)
abstract class AppDatabase : RoomDatabase() {
    abstract fun voiceNoteDao(): VoiceNoteDao
}

@Suppress("KotlinNoActualForExpect")
expect object AppDatabaseConstructor : RoomDatabaseConstructor<AppDatabase> {
    override fun initialize(): AppDatabase
}

fun getRoomDatabase(builder: RoomDatabase.Builder<AppDatabase>): AppDatabase =
    builder
        .addMigrations(MIGRATION_1_2, MIGRATION_2_3)
        .setDriver(BundledSQLiteDriver())
        .setQueryCoroutineContext(databaseCoroutineContext)
        .build()

private val MIGRATION_1_2 = object : Migration(1, 2) {
    override fun migrate(connection: SQLiteConnection) {
        connection.execSQL("DROP TABLE IF EXISTS museum_objects")
        connection.execSQL(
            """
            CREATE TABLE IF NOT EXISTS voice_notes (
                id TEXT NOT NULL PRIMARY KEY,
                title TEXT NOT NULL,
                summary TEXT NOT NULL,
                transcript TEXT NOT NULL,
                createdAtEpochMillis INTEGER NOT NULL,
                durationMillis INTEGER NOT NULL,
                source TEXT NOT NULL
            )
            """.trimIndent(),
        )
    }
}

private val MIGRATION_2_3 = object : Migration(2, 3) {
    override fun migrate(connection: SQLiteConnection) {
        connection.execSQL("ALTER TABLE voice_notes ADD COLUMN checklist TEXT NOT NULL DEFAULT ''")
    }
}
