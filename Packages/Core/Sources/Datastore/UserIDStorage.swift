import Foundation

/// userID の保存。userID は秘匿情報として扱うため Keychain に保存する。
/// NiA 相当: core:datastore の `NiaPreferencesDataSource`（設定値の保存。Keychain は iOS 固有）。
nonisolated public protocol UserIDStorage: Sendable {
    nonisolated func save(_ userID: String) throws
    /// 保存済みの userID を返す（未保存なら nil。読み取り失敗時は throw）。
    nonisolated func load() throws -> String?
}

/// Keychain に userID を保存するデータソース。実際の Keychain 操作は `KeyChainUtil` に委譲する。
nonisolated public struct KeychainUserIDStorage: UserIDStorage {
    private let serviceName: String
    private let username: String

    public init(
        serviceName: String = "com.example.iOS-POC-2.auth",
        username: String = "user_id"
    ) {
        self.serviceName = serviceName
        self.username = username
    }

    nonisolated public func save(_ userID: String) throws {
        try KeyChainUtil.save(userID, username: username, serviceName: serviceName)
    }

    nonisolated public func load() throws -> String? {
        try KeyChainUtil.get(username: username, serviceName: serviceName)
    }
}
