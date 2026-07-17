import Foundation

/// 認証 API のリモートデータソース。
public protocol AuthRemoteDataSource: Sendable {
    /// ログインし、サーバーが払い出した userID を返す。
    func login(email: String, password: String) async throws -> String
}

/// 実際の通信は行わず、一定時間後に userID を返すフェイク実装。
public struct FakeAuthRemoteDataSource: AuthRemoteDataSource {
    public init() {}

    public func login(email: String, password: String) async throws -> String {
        // ネットワーク遅延を模して 1 秒待つ。
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        // サーバーが払い出す想定の userID。
        return "user-\(UUID().uuidString.prefix(8))"
    }
}
