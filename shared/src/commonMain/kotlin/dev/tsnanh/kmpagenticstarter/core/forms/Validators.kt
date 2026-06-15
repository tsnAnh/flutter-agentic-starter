package dev.tsnanh.kmpagenticstarter.core.forms

data class ValidationResult(val isValid: Boolean, val message: String? = null)

object Validators {
    fun required(value: String, message: String = "Required"): ValidationResult =
        if (value.isBlank()) ValidationResult(false, message) else ValidationResult(true)

    fun email(value: String): ValidationResult {
        val isValid = Regex("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$").matches(value)
        return if (isValid) ValidationResult(true) else ValidationResult(false, "Invalid email")
    }
}
