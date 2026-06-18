package dev.tsnanh.kmpagenticstarter.features.home.data

import dev.tsnanh.kmpagenticstarter.features.home.data.datasources.MuseumObjectDto
import dev.tsnanh.kmpagenticstarter.features.home.data.datasources.MuseumObjectEntity
import dev.tsnanh.kmpagenticstarter.features.home.domain.models.MuseumObject

internal fun MuseumObjectDto.toDomain() = MuseumObject(
    objectID = objectID,
    title = title,
    artistDisplayName = artistDisplayName,
    medium = medium,
    dimensions = dimensions,
    objectURL = objectURL,
    objectDate = objectDate,
    primaryImage = primaryImage,
    primaryImageSmall = primaryImageSmall,
    repository = repository,
    department = department,
    creditLine = creditLine,
)

internal fun MuseumObject.toEntity() = MuseumObjectEntity(
    objectID = objectID,
    title = title,
    artistDisplayName = artistDisplayName,
    medium = medium,
    dimensions = dimensions,
    objectURL = objectURL,
    objectDate = objectDate,
    primaryImage = primaryImage,
    primaryImageSmall = primaryImageSmall,
    repository = repository,
    department = department,
    creditLine = creditLine,
)

internal fun MuseumObjectEntity.toDomain() = MuseumObject(
    objectID = objectID,
    title = title,
    artistDisplayName = artistDisplayName,
    medium = medium,
    dimensions = dimensions,
    objectURL = objectURL,
    objectDate = objectDate,
    primaryImage = primaryImage,
    primaryImageSmall = primaryImageSmall,
    repository = repository,
    department = department,
    creditLine = creditLine,
)
