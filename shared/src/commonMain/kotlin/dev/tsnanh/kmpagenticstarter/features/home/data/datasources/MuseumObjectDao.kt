package dev.tsnanh.kmpagenticstarter.features.home.data.datasources

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Transaction
import kotlinx.coroutines.flow.Flow

@Dao
interface MuseumObjectDao {
    @Query("SELECT * FROM museum_objects ORDER BY objectID")
    fun objects(): Flow<List<MuseumObjectEntity>>

    @Query("SELECT * FROM museum_objects WHERE objectID = :objectId")
    fun objectById(objectId: Int): Flow<MuseumObjectEntity?>

    @Transaction
    suspend fun replaceObjects(objects: List<MuseumObjectEntity>) {
        clearObjects()
        insertObjects(objects)
    }

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertObjects(objects: List<MuseumObjectEntity>)

    @Query("DELETE FROM museum_objects")
    suspend fun clearObjects()
}
