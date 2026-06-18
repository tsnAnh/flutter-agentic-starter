package dev.tsnanh.kmpagenticstarter.core.forms

import arrow.core.Either
import arrow.core.EitherNel
import arrow.core.left
import arrow.core.leftNel
import arrow.core.nonEmptyListOf
import arrow.core.right

object Validators {
    fun required(value: String, message: String = "Required"): EitherNel<String, Unit> =
        if (value.isBlank()) message.leftNel() else Unit.right()

    fun email(value: String): EitherNel<String, Unit> {
        val isValid = Regex("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$").matches(value)
        return if (isValid) Unit.right() else "Invalid email".leftNel()
    }

    fun all(vararg results: EitherNel<String, Unit>): EitherNel<String, Unit> {
        val errors = results.fold(emptyList<String>()) { acc, result ->
            when (result) {
                is Either.Left -> acc + result.value
                is Either.Right -> acc
            }
        }
        return if (errors.isEmpty()) {
            Unit.right()
        } else {
            nonEmptyListOf(errors.first(), *errors.drop(1).toTypedArray()).left()
        }
    }
}
