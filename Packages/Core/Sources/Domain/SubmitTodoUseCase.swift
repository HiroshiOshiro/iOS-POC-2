import Foundation

/// Todo を確定保存するユースケース。
public protocol SubmitTodoUseCase: Sendable {
    func execute(text: String) async
}

public struct SubmitTodoUseCaseImpl: SubmitTodoUseCase {
    private let repository: any TodoRepository

    public init(repository: any TodoRepository) {
        self.repository = repository
    }

    public func execute(text: String) async {
        await repository.submit(Todo(text: text))
    }
}
