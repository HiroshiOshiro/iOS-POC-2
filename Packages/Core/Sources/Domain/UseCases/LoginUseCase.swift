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
        // 入力チェック（UseCase 固有の責務。Data 層には無い失敗）。
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty, !password.isEmpty else {
            throw AuthError.validation
        }
        // Repository（Data 層）は AuthDataError を投げる。Domain の語彙 AuthError へ変換する。
        do {
            return try await repository.login(email: trimmedEmail, password: password)
        } catch let error as AuthDataError {
            throw AuthError(dataError: error)
        }
    }
}
