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
        // 入力チェック（UseCase の責務）。以降の段は Repository が LoginFailure に変換する。
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            throw LoginFailure.validation
        }
        return try await repository.login(email: trimmedEmail, password: password)
    }
}
