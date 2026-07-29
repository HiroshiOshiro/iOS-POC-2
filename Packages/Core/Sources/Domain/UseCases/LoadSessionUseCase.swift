import Foundation
import Model
import Data

/// 保存済みのセッションを読み出すユースケース。
/// NiA 相当: core:domain の UseCase（例: `GetFollowableTopicsUseCase`）。
nonisolated public protocol LoadSessionUseCase: Sendable {
    nonisolated func execute() async -> Session?
}

nonisolated public struct DefaultLoadSessionUseCase: LoadSessionUseCase {
    private let repository: any AuthRepository

    public init(repository: any AuthRepository) {
        self.repository = repository
    }

    nonisolated public func execute() async -> Session? {
        await repository.currentSession()
    }
}
