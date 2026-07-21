import Foundation

/// 認証 API のリモートデータソース。
/// NiA 相当: core:network の `NiaNetworkDataSource`（リモートデータソースの抽象）。
public protocol AuthRemoteDataSource: Sendable {
    /// ログインし、サーバーが払い出した userID を返す。
    func login(email: String, password: String) async throws -> String
}

/// 認証で起きうるエラー。
public enum AuthRemoteError: Error {
    case invalidCredentials
}

/// 実際の通信は行わず、一定時間後に userID を返すフェイク実装。
/// NiA 相当: core:network の `DemoNiaNetworkDataSource`（デモ/フェイク実装）。
public struct FakeAuthRemoteDataSource: AuthRemoteDataSource {
    public init() {}

    public func login(email: String, password: String) async throws -> String {
        // ネットワーク遅延を模して 1 秒待つ。
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        // エラー処理のサンプル: メールアドレスに "fail" を含むときは認証失敗を模す。
        // （パスワードは Repository で暗号化されてから届くため、判定はメールで行う）
        if email.lowercased().contains("fail") {
            throw AuthRemoteError.invalidCredentials
        }
        // サーバーが払い出す想定の userID。
        return "user-\(UUID().uuidString.prefix(8))"
    }
}
