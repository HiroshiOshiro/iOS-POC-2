import Foundation
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

    public init(
        remote: any AuthRemoteDataSource = FakeAuthRemoteDataSource(),
        passwordEncryptor: any PasswordEncrypting = CryptoKitPasswordEncryptor(),
        emailStorage: any EmailStorage = UserDefaultsEmailStorage(key: StorageKeys.loginEmail),
        userIDStorage: any UserIDStorage = KeychainUserIDStorage()
    ) {
        self.remote = remote
        self.passwordEncryptor = passwordEncryptor
        self.emailStorage = emailStorage
        self.userIDStorage = userIDStorage
    }

    public func login(email: String, password: String) async throws -> Session {
        // 通信前にパスワードを暗号化する（interface 経由なので実装が ObjC か Swift かは意識しない）。
        let encryptedPassword = try passwordEncryptor.encrypt(password)
        let userID = try await remote.login(email: email, password: encryptedPassword)
        emailStorage.save(email)
        try userIDStorage.save(userID)
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
