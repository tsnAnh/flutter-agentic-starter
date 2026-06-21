package dev.tsnanh.creativenote.projectsetup

import java.io.File

data class SetupOptions(
    val appName: String,
    val packageName: String,
    val appId: String,
    val dryRun: Boolean,
)

fun main(args: Array<String>) {
    val options = parseOptions(args)
    validate(options)

    val root = File(System.getProperty("user.dir")).canonicalFile
        .takeIf { it.resolve("settings.gradle.kts").exists() }
        ?: File(System.getProperty("user.dir")).canonicalFile.parentFile.parentFile
    val oldPackage = "dev.tsnanh.creativenote"
    val replacements = listOf(
        "Creative Note" to options.appName,
        "creative-note" to options.appName.slug(),
        oldPackage to options.packageName,
        "dev.tsnanh.creativenote.shared" to "${options.packageName}.shared",
    )
    val changed = mutableListOf<String>()

    root.walkTopDown()
        .filter { it.isFile && it.extension in textExtensions }
        .filterNot { it.path.contains("/.git/") || it.path.contains("/build/") }
        .forEach { file ->
            if (replaceInFile(file, replacements, options.dryRun)) {
                changed += file.relativeTo(root).path
            }
        }

    listOf(
        root.resolve("shared/src/commonMain/kotlin"),
        root.resolve("shared/src/commonTest/kotlin"),
        root.resolve("shared/src/iosMain/kotlin"),
        root.resolve("androidApp/src/main/kotlin"),
    ).forEach { sourceRoot ->
        if (movePackageRoot(sourceRoot, oldPackage, options.packageName, options.dryRun)) {
            changed += sourceRoot.relativeTo(root).path
        }
    }

    val env = root.resolve(".env")
    if (!options.dryRun && !env.exists()) {
        env.writeText(
            """
            # Local secrets. Do not commit.
            POSTHOG_API_KEY=
            POSTHOG_HOST=https://app.posthog.com
            FIREBASE_PROJECT_ID=
            """.trimIndent() + "\n"
        )
    }

    println(if (options.dryRun) "Dry run. No files written." else "Project setup complete.")
    changed.distinct().forEach { println("- $it") }
}

private fun parseOptions(args: Array<String>): SetupOptions {
    fun value(name: String): String? =
        args.indexOf(name).takeIf { it >= 0 && it + 1 < args.size }?.let { args[it + 1] }

    val packageName = value("--kotlin-package-name") ?: value("--package-name") ?: "dev.tsnanh.creativenote"
    return SetupOptions(
        appName = value("--app-name") ?: "Creative Note",
        packageName = packageName,
        appId = value("--app-id") ?: packageName,
        dryRun = "--dry-run" in args,
    )
}

private fun validate(options: SetupOptions) {
    val packagePattern = Regex("^[a-z][a-z0-9_]*(\\.[a-z][a-z0-9_]*)+$")
    require(packagePattern.matches(options.packageName)) {
        "Package must be reverse-domain lowercase, e.g. dev.tsnanh.creativenote"
    }
    require(packagePattern.matches(options.appId)) {
        "App ID must be reverse-domain lowercase, e.g. dev.tsnanh.creativenote"
    }
}

private fun replaceInFile(
    file: File,
    replacements: List<Pair<String, String>>,
    dryRun: Boolean,
): Boolean {
    val original = file.readText()
    val updated = replacements.fold(original) { content, (from, to) -> content.replace(from, to) }
    if (original == updated) return false
    if (!dryRun) file.writeText(updated)
    return true
}

private fun movePackageRoot(
    root: File,
    oldPackage: String,
    newPackage: String,
    dryRun: Boolean,
): Boolean {
    val oldDir = root.resolve(oldPackage.replace('.', '/'))
    if (!oldDir.exists()) return false
    val newDir = root.resolve(newPackage.replace('.', '/'))
    if (!dryRun) {
        newDir.parentFile.mkdirs()
        oldDir.copyRecursively(newDir, overwrite = true)
        oldDir.deleteRecursively()
    }
    return true
}

private fun String.slug(): String =
    lowercase().replace(Regex("[^a-z0-9]+"), "-").trim('-')

private val textExtensions = setOf("kt", "kts", "swift", "xml", "plist", "pbxproj", "xcconfig", "md", "json", "toml", "yml")
