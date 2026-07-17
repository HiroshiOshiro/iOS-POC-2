import Foundation

/// ログイン済みのセッション。
public struct Session: Sendable, Equatable {
    public let email: String
    public let userID: String

    public init(email: String, userID: String) {
        self.email = email
        self.userID = userID
    }
}
