import Foundation

/// userID の保存。userID は秘匿情報として扱うため Keychain に保存する。
public protocol UserIDStorage: Sendable {
    func save(_ userID: String) throws
    /// 保存済みの userID を返す（未保存なら nil。読み取り失敗時は throw）。
    func load() throws -> String?
}

/// Keychain に userID を保存するデータソース。実際の Keychain 操作は `KeyChainUtil` に委譲する。
public struct KeychainUserIDStorage: UserIDStorage {
    private let serviceName: String
    private let username: String

    public init(
        serviceName: String = "com.example.iOS-POC-2.auth",
        username: String = "user_id"
    ) {
        self.serviceName = serviceName
        self.username = username
    }

    public func save(_ userID: String) throws {
        try KeyChainUtil.save(userID, username: username, serviceName: serviceName)
    }

    public func load() throws -> String? {
        try KeyChainUtil.get(username: username, serviceName: serviceName)
    }
}
