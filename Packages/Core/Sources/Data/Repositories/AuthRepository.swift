import Foundation
import Common
import Model
import Network
import Datastore

/// 認証まわりの通信・永続化を抽象化したリポジトリ。
/// NiA 相当: core:data の `UserDataRepository`（リポジトリ抽象）。
public protocol AuthRepository: Sendable {
    /// ログインし、メールアドレスと userID を永続化する。
    func login(email: String, password: String) async throws -> Session
    /// 保存済みのセッションを返す（未ログインなら nil）。
    func currentSession() async -> Session?
}

/// `AuthRepository` の実装。
/// モック API でログインし、メールアドレスは UserDefaults（＝@AppStorage と同じ場所）、
/// userID は Keychain に保存する。
/// NiA 相当: core:data の `OfflineFirstUserDataRepository`（リポジトリ実装）。
public actor DefaultAuthRepository: AuthRepository {
    private let remote: any AuthRemoteDataSource
    private let passwordEncryptor: any PasswordEncrypting
    private let emailStorage: any EmailStorage
    private let userIDStorage: any UserIDStorage

    // 依存はすべて DI コンテナ（Container+Repository）から注入する。
    public init(
        remote: any AuthRemoteDataSource,
        passwordEncryptor: any PasswordEncrypting,
        emailStorage: any EmailStorage,
        userIDStorage: any UserIDStorage
    ) {
        self.remote = remote
        self.passwordEncryptor = passwordEncryptor
        self.emailStorage = emailStorage
        self.userIDStorage = userIDStorage
    }

    public func login(email: String, password: String) async throws -> Session {
        // デモ: ログイン前の共有トークンを読む（ObjC が起動時に入れた値が見える）。
        log("TokenManager read (Swift, before): \(TokenManager.shared.token ?? "nil")")
        // 通信前にパスワードを暗号化する（interface 経由なので実装が ObjC か Swift かは意識しない）。
        let encryptedPassword = try passwordEncryptor.encrypt(password)
        let userID = try await remote.login(email: email, password: encryptedPassword)
        emailStorage.save(email)
        try userIDStorage.save(userID)
        // デモ: API から取得したトークン（を模した値）をアプリ全体の in-memory ストアへ保存。
        TokenManager.shared.token = "api-token-\(userID)"
        log("TokenManager wrote (Swift): \(TokenManager.shared.token ?? "nil")")
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
}
