import Foundation

/// ログイン済みのセッション。
/// NiA 相当: core:model の `UserData`（ユーザー状態のモデル）。
public struct Session: Sendable, Equatable {
    public let email: String
    public let userID: String

    public init(email: String, userID: String) {
        self.email = email
        self.userID = userID
    }
}
