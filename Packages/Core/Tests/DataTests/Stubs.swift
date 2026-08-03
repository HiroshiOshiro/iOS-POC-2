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

enum StubError: Error { case boom }

final class StubAuthRemote: AuthRemoteDataSource, @unchecked Sendable {
    let userID: String
    let shouldThrow: Bool
    private(set) var receivedPassword: String?
    init(userID: String = "user-1", shouldThrow: Bool = false) {
        self.userID = userID
        self.shouldThrow = shouldThrow
    }

    func login(email: String, password: String) async throws -> String {
        receivedPassword = password
        if shouldThrow { throw StubError.boom }
        return userID
    }
}

struct StubPasswordEncryptor: PasswordEncrypting {
    let shouldThrow: Bool
    init(shouldThrow: Bool = false) { self.shouldThrow = shouldThrow }
    /// 暗号化されたことを検証できるよう、前後関係の分かる変換にする。
    func encrypt(_ password: String) throws -> String {
        if shouldThrow { throw StubError.boom }
        return "ENC(\(password))"
    }
}

final class StubEmailStorage: EmailStorage, @unchecked Sendable {
    private(set) var saved: String?
    init(saved: String? = nil) { self.saved = saved }

    func save(_ email: String) { saved = email }
    func load() -> String? { saved }
}

final class StubUserIDStorage: UserIDStorage, @unchecked Sendable {
    private(set) var saved: String?
    let shouldThrowOnSave: Bool
    init(saved: String? = nil, shouldThrowOnSave: Bool = false) {
        self.saved = saved
        self.shouldThrowOnSave = shouldThrowOnSave
    }

    func save(_ userID: String) throws {
        if shouldThrowOnSave { throw StubError.boom }
        saved = userID
    }
    func load() throws -> String? { saved }
}

final class StubTokenStore: TokenStoring, @unchecked Sendable {
    var token: String?
    init(token: String? = nil) { self.token = token }

    func clear() { token = nil }
}

final class StubMusicRemote: MusicRemoteDataSource, @unchecked Sendable {
    var dtos: [ITunesTrackDTO]
    var errorToThrow: Error?
    private(set) var receivedTerm: String?
    init(dtos: [ITunesTrackDTO] = [], errorToThrow: Error? = nil) {
        self.dtos = dtos
        self.errorToThrow = errorToThrow
    }

    func search(term: String) async throws -> [ITunesTrackDTO] {
        receivedTerm = term
        if let errorToThrow { throw errorToThrow }
        return dtos
    }
}
