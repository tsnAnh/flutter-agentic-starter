package dev.tsnanh.kmpagenticstarter.core.base

interface UseCase<in Input, Output> {
    suspend operator fun invoke(input: Input): DataState<Output>
}

interface NoInputUseCase<Output> {
    suspend operator fun invoke(): DataState<Output>
}
