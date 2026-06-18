package dev.tsnanh.kmpagenticstarter.features.home.data.datasources

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "museum_objects")
data class MuseumObjectEntity(
    @PrimaryKey val objectID: Int,
    val title: String,
    val artistDisplayName: String,
    val medium: String,
    val dimensions: String,
    val objectURL: String,
    val objectDate: String,
    val primaryImage: String,
    val primaryImageSmall: String,
    val repository: String,
    val department: String,
    val creditLine: String,
)
