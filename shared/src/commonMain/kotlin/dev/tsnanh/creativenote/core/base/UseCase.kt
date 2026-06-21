package dev.tsnanh.creativenote.core.base

interface UseCase<in Input, Output> {
    suspend operator fun invoke(input: Input): AppResult<Output>
}

interface NoInputUseCase<Output> {
    suspend operator fun invoke(): AppResult<Output>
}
