import Foundation
import Model
import Data

/// ログインを実行するユースケース。
/// NiA 相当: core:domain の UseCase（例: `GetFollowableTopicsUseCase`）。
nonisolated public protocol LoginUseCase: Sendable {
    nonisolated func execute(email: String, password: String) async throws -> Session
}

nonisolated public struct DefaultLoginUseCase: LoginUseCase {
    private let repository: any AuthRepository

    public init(repository: any AuthRepository) {
        self.repository = repository
    }

    nonisolated public func execute(email: String, password: String) async throws -> Session {
        try await repository.login(email: email, password: password)
    }
}
