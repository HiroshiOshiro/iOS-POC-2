import Foundation
import Model
import Data

/// Todo を確定保存するユースケース。
/// NiA 相当: core:domain の UseCase（例: `GetFollowableTopicsUseCase`）。
public protocol SubmitTodoUseCase: Sendable {
    func execute(text: String) async
}

public struct DefaultSubmitTodoUseCase: SubmitTodoUseCase {
    private let repository: any TodoRepository

    public init(repository: any TodoRepository) {
        self.repository = repository
    }

    public func execute(text: String) async {
        await repository.submit(Todo(text: text))
    }
}
