import Foundation
import Domain
import Network
import LocalStorage

/// `AuthRepository` の実装。
/// モック API でログインし、メールアドレスは UserDefaults（＝@AppStorage と同じ場所）、
/// userID は Keychain に保存する。
public actor AuthRepositoryImpl: AuthRepository {
    private let remote: any AuthRemoteDataSource
    private let emailStorage: any EmailStorage
    private let userIDStorage: any UserIDStorage

    public init(
        remote: any AuthRemoteDataSource = MockAuthRemoteDataSource(),
        emailStorage: any EmailStorage = UserDefaultsEmailStorage(),
        userIDStorage: any UserIDStorage = KeychainUserIDStorage()
    ) {
        self.remote = remote
        self.emailStorage = emailStorage
        self.userIDStorage = userIDStorage
    }

    public func login(email: String, password: String) async throws -> Session {
        let userID = try await remote.login(email: email, password: password)
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
