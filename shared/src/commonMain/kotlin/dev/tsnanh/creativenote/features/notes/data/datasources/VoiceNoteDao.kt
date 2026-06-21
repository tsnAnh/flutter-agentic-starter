package dev.tsnanh.creativenote.features.notes.data.datasources

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface VoiceNoteDao {
    @Query("SELECT * FROM voice_notes ORDER BY createdAtEpochMillis DESC")
    fun notes(): Flow<List<VoiceNoteEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(note: VoiceNoteEntity)
}
