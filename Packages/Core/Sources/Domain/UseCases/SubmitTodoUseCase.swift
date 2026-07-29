import Foundation
import Model
import Data

/// Todo を確定保存するユースケース。
/// NiA 相当: core:domain の UseCase（例: `GetFollowableTopicsUseCase`）。
nonisolated public protocol SubmitTodoUseCase: Sendable {
    nonisolated func execute(text: String) async throws
}

nonisolated public struct DefaultSubmitTodoUseCase: SubmitTodoUseCase {
    private let repository: any TodoRepository

    public init(repository: any TodoRepository) {
        self.repository = repository
    }

    nonisolated public func execute(text: String) async throws {
        try await repository.submit(Todo(text: text))
    }
}
