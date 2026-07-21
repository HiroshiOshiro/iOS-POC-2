import Foundation
import Model
import Data

/// ログインを実行するユースケース。
/// NiA 相当: core:domain の UseCase（例: `GetFollowableTopicsUseCase`）。
public protocol LoginUseCase: Sendable {
    func execute(email: String, password: String) async throws -> Session
}

public struct DefaultLoginUseCase: LoginUseCase {
    private let repository: any AuthRepository

    public init(repository: any AuthRepository) {
        self.repository = repository
    }

    public func execute(email: String, password: String) async throws -> Session {
        try await repository.login(email: email, password: password)
    }
}
