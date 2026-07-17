import Foundation

/// 保存済みのセッションを読み出すユースケース。
public protocol LoadSessionUseCase: Sendable {
    func execute() async -> Session?
}

public struct LoadSessionUseCaseImpl: LoadSessionUseCase {
    private let repository: any AuthRepository

    public init(repository: any AuthRepository) {
        self.repository = repository
    }

    public func execute() async -> Session? {
        await repository.currentSession()
    }
}
