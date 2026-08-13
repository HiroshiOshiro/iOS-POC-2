import Foundation
import Common
import FactoryKit
import Model
import Networking
import Datastore

/// 認証まわりの通信・永続化を抽象化したリポジトリ。
/// NiA 相当: core:data の `UserDataRepository`（リポジトリ抽象）。
public protocol AuthRepository: Sendable {
    /// ログインし、メールアドレスと userID を永続化する。
    func login(email: String, password: String) async throws -> Session
    /// 保存済みのセッションを返す（未ログインなら nil）。
    func currentSession() async -> Session?
    /// 現在保持しているトークンをアクセス許可 API に送り、許可の有無を返す。
    func checkAccessPermission() async throws -> Bool
}

/// `AuthRepository` の実装。
/// モック API でログインし、メールアドレスは UserDefaults（＝@AppStorage と同じ場所）、
/// userID は Keychain に保存する。
/// NiA 相当: core:data の `OfflineFirstUserDataRepository`（リポジトリ実装）。
public actor DefaultAuthRepository: AuthRepository {
    // 依存は Factory から直接注入する（@Injected）。テストは Container に register して差し替える。
    @Injected(\.authRemoteDataSource) private var remote
    @Injected(\.passwordEncryptor) private var passwordEncryptor
    @Injected(\.emailStorage) private var emailStorage
    @Injected(\.userIDStorage) private var userIDStorage
    // tokenManager は Container 経由で解決すると ObjC が使う `.shared` と同一インスタンスになる。
    @Injected(\.tokenManager) private var tokenManager

    public init() {}

    /// 複数段（暗号化→通信→保存）を順に実行し、**失敗した段を `AuthDataError` に変換**して投げる。
    /// これは Data 層の語彙。上位（UseCase）が `AuthError` へ再変換して受け取る。
    public func login(email: String, password: String) async throws -> Session {
        // デモ: ログイン前の共有トークンを読む（ObjC が起動時に入れた値が見える）。
        log("TokenManager read (Swift, before): \(tokenManager.token ?? "nil")")

        // 1) パスワード暗号化（interface 経由なので実装が ObjC か Swift かは意識しない）。
        let encryptedPassword: String
        do {
            encryptedPassword = try passwordEncryptor.encrypt(password)
        } catch {
            throw AuthDataError.encryption
        }

        // 2) 通信（共有の TransportFailure を内包）。
        let userID: String
        do {
            userID = try await remote.login(email: email, password: encryptedPassword)
        } catch {
            throw AuthDataError.transport(.network)
        }

        emailStorage.save(email) // UserDefaults 保存（失敗しない）

        // 3) 保存（userID を Keychain へ）。
        do {
            try userIDStorage.save(userID)
        } catch {
            throw AuthDataError.persistence
        }

        // デモ: API から取得したトークン（を模した値）をアプリ全体の in-memory ストアへ保存。
        tokenManager.token = "api-token-\(userID)"
        log("TokenManager wrote (Swift): \(tokenManager.token ?? "nil")")
        log("ログイン成功 userID=\(userID)")
        return Session(email: email, userID: userID)
    }

    public func currentSession() async -> Session? {
        // 復元用途のため、Keychain の読み取り失敗は「未ログイン」として扱う。
        let storedUserID = (try? userIDStorage.load()) ?? nil
        guard let email = emailStorage.load(), !email.isEmpty,
              let userID = storedUserID
        else {
            return nil
        }
        return Session(email: email, userID: userID)
    }

    /// 通信前チェック（`MusicRepository.search` の `networkMonitor.isReachable` と同じ型）：
    /// トークンが無ければ通信を試みずに失敗させる。
    public func checkAccessPermission() async throws -> Bool {
        guard let token = tokenManager.token else {
            throw AuthDataError.missingToken
        }
        do {
            return try await remote.checkAccessPermission(token: token)
        } catch {
            throw AuthDataError.transport(.network)
        }
    }
}
