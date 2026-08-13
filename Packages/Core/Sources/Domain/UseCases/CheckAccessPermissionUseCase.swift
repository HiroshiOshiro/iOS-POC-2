import Foundation
import Model
import Data

/// 現在のトークンにアクセス許可があるかを確認するユースケース。
/// NiA 相当: core:domain の UseCase（例: `GetFollowableTopicsUseCase`）。
public protocol CheckAccessPermissionUseCase: Sendable {
    func execute() async throws -> Bool
}

public struct DefaultCheckAccessPermissionUseCase: CheckAccessPermissionUseCase {
    private let repository: any AuthRepository

    public init(repository: any AuthRepository) {
        self.repository = repository
    }

    public func execute() async throws -> Bool {
        // Repository（Data 層）は AuthDataError を投げる。Domain の語彙 AuthError へ変換する。
        do {
            return try await repository.checkAccessPermission()
        } catch let error as AuthDataError {
            throw AuthError(dataError: error)
        }
    }
}
