import Foundation
import Common

/// 認証 API のリモートデータソース。
/// NiA 相当: core:network の `NiaNetworkDataSource`（リモートデータソースの抽象）。
nonisolated public protocol AuthRemoteDataSource: Sendable {
    /// ログインし、サーバーが払い出した userID を返す。
    nonisolated func login(email: String, password: String) async throws -> String
}

/// 認証で起きうるエラー。
nonisolated public enum AuthRemoteError: Error {
    case invalidCredentials
}

/// 実際の通信は行わず、一定時間後に userID を返すフェイク実装。
/// NiA 相当: core:network の `DemoNiaNetworkDataSource`（デモ/フェイク実装）。
nonisolated public struct FakeAuthRemoteDataSource: AuthRemoteDataSource {
    public init() {}

    nonisolated public func login(email: String, password: String) async throws -> String {
        // 通信ログ（パスワードは秘匿情報のため出力しない）。
        log("▶ Request POST /auth/login email=\(email)")
        let start = Date()
        // ネットワーク遅延を模して 1 秒待つ。
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        let elapsedMs = Int(Date().timeIntervalSince(start) * 1000)
        // エラー処理のサンプル: メールアドレスに "fail" を含むときは認証失敗を模す。
        // （パスワードは Repository で暗号化されてから届くため、判定はメールで行う）
        if email.lowercased().contains("fail") {
            log("◀ Response 401 POST /auth/login (\(elapsedMs) ms) invalidCredentials")
            throw AuthRemoteError.invalidCredentials
        }
        // サーバーが払い出す想定の userID。
        let userID = "user-\(UUID().uuidString.prefix(8))"
        log("◀ Response 200 POST /auth/login (\(elapsedMs) ms) userID=\(userID)")
        return userID
    }
}
