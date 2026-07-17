import Foundation

/// 認証まわりの通信・永続化を抽象化したリポジトリ。実装は Data 層が提供する。
public protocol AuthRepository: Sendable {
    /// ログインし、メールアドレスと userID を永続化する。
    func login(email: String, password: String) async throws -> Session
    /// 保存済みのセッションを返す（未ログインなら nil）。
    func currentSession() async -> Session?
}
