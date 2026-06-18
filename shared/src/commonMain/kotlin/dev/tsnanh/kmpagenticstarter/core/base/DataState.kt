package dev.tsnanh.kmpagenticstarter.core.base

import arrow.core.Either
import arrow.core.Option
import dev.tsnanh.kmpagenticstarter.core.error.AppError

typealias AppResult<T> = Either<AppError, T>
typealias AsyncResult<T> = Option<AppResult<T>>
typealias OptionalResult<T> = AppResult<Option<T>>
