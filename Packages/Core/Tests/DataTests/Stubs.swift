import Foundation
import Model
import Network
import Database
import Datastore
@testable import Data

// テスト用のスタブ。逐次的に await して使うため、状態は素朴な可変プロパティで保持し
// `@unchecked Sendable` で Sendable 要求を満たす（本番実装ではないテスト専用）。

final class StubTodoRemote: TodoRemoteDataSource, @unchecked Sendable {
    let shouldThrow: Bool
    private(set) var submittedTexts: [String] = []
    init(shouldThrow: Bool = false) { self.shouldThrow = shouldThrow }

    func submit(text: String) async throws {
        submittedTexts.append(text)
        if shouldThrow { throw TodoRemoteError.submitFailed }
    }
}

final class StubTodoLocal: TodoLocalDataSource, @unchecked Sendable {
    private(set) var records: [TodoRecord]
    init(records: [TodoRecord] = []) { self.records = records }

    func load() -> [TodoRecord] { records }
    func save(_ todos: [TodoRecord]) { records = todos }
}

final class StubAuthRemote: AuthRemoteDataSource, @unchecked Sendable {
    let userID: String
    private(set) var receivedPassword: String?
    init(userID: String = "user-1") { self.userID = userID }

    func login(email: String, password: String) async throws -> String {
        receivedPassword = password
        return userID
    }
}

struct StubPasswordEncryptor: PasswordEncrypting {
    /// 暗号化されたことを検証できるよう、前後関係の分かる変換にする。
    func encrypt(_ password: String) throws -> String { "ENC(\(password))" }
}

final class StubEmailStorage: EmailStorage, @unchecked Sendable {
    private(set) var saved: String?
    init(saved: String? = nil) { self.saved = saved }

    func save(_ email: String) { saved = email }
    func load() -> String? { saved }
}

final class StubUserIDStorage: UserIDStorage, @unchecked Sendable {
    private(set) var saved: String?
    init(saved: String? = nil) { self.saved = saved }

    func save(_ userID: String) throws { saved = userID }
    func load() throws -> String? { saved }
}

final class StubTokenStore: TokenStoring, @unchecked Sendable {
    var token: String?
    init(token: String? = nil) { self.token = token }

    func clear() { token = nil }
}
