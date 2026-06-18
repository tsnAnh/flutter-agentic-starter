package dev.tsnanh.kmpagenticstarter.features.home

import dev.tsnanh.kmpagenticstarter.features.home.data.datasources.MuseumObjectDto
import dev.tsnanh.kmpagenticstarter.features.home.data.toDomain
import dev.tsnanh.kmpagenticstarter.features.home.data.toEntity
import kotlin.test.Test
import kotlin.test.assertEquals

class MuseumMappersTest {
    @Test
    fun dtoAndEntityMapToDomain() {
        val domain = dto().toDomain()
        val entityDomain = domain.toEntity().toDomain()

        assertEquals(domain, entityDomain)
        assertEquals("Starter Object", entityDomain.title)
    }

    private fun dto() = MuseumObjectDto(
        objectID = 1,
        title = "Starter Object",
        artistDisplayName = "AnyFoundry",
        medium = "Kotlin",
        dimensions = "1 file",
        objectURL = "https://example.com",
        objectDate = "2026",
        primaryImage = "https://example.com/full.png",
        primaryImageSmall = "https://example.com/small.png",
        repository = "KMP Agentic Starter",
        department = "Architecture",
        creditLine = "Template",
    )
}
