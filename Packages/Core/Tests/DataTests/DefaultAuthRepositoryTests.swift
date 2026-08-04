import Testing
import FactoryKit
import Model
import Network
import Datastore
@testable import Data

// @Injected は Container.shared から解決するため、スタブは register で差し替える。
@Suite(.serialized)
struct DefaultAuthRepositoryTests {

    /// 依存をスタブに差し替えて SUT を作る。
    private func makeSUT(
        remote: StubAuthRemote = StubAuthRemote(),
        encryptor: StubPasswordEncryptor = StubPasswordEncryptor(),
        email: StubEmailStorage = StubEmailStorage(),
        userID: StubUserIDStorage = StubUserIDStorage(),
        tokenStore: StubTokenStore = StubTokenStore()
    ) -> DefaultAuthRepository {
        Container.shared.authRemoteDataSource.register { remote }
        Container.shared.passwordEncryptor.register { encryptor }
        Container.shared.emailStorage.register { email }
        Container.shared.userIDStorage.register { userID }
        Container.shared.tokenManager.register { tokenStore }
        return DefaultAuthRepository()
    }

    // MARK: - 段別エラーへのマッピング（どこで失敗したか → LoginFailure）

    @Test("Given encryption fails, when login, then it throws LoginFailure.encryption")
    func mapsEncryptionFailure() async {
        let sut = makeSUT(encryptor: StubPasswordEncryptor(shouldThrow: true))
        await #expect(throws: LoginFailure.encryption) {
            try await sut.login(email: "user@example.com", password: "pw")
        }
    }

    @Test("Given the remote fails, when login, then it throws LoginFailure.transport(.network)")
    func mapsNetworkFailure() async {
        let sut = makeSUT(remote: StubAuthRemote(shouldThrow: true))
        await #expect(throws: LoginFailure.transport(.network)) {
            try await sut.login(email: "user@example.com", password: "pw")
        }
    }

    @Test("Given the userID save fails, when login, then it throws LoginFailure.persistence")
    func mapsPersistenceFailure() async {
        let sut = makeSUT(userID: StubUserIDStorage(shouldThrowOnSave: true))
        await #expect(throws: LoginFailure.persistence) {
            try await sut.login(email: "user@example.com", password: "pw")
        }
    }

    @Test("Given login, when it is called, then the password is encrypted before reaching the remote")
    func encryptsPasswordBeforeRemote() async throws {
        let remote = StubAuthRemote()
        let sut = makeSUT(remote: remote)

        _ = try await sut.login(email: "user@example.com", password: "secret")

        #expect(remote.receivedPassword == "ENC(secret)") // 生パスワードではない
    }

    @Test("Given login succeeds, when it is called, then email and userID are persisted, the token is stored, and a session is returned")
    func persistsAndReturnsSession() async throws {
        let email = StubEmailStorage()
        let userID = StubUserIDStorage()
        let tokenStore = StubTokenStore()
        let sut = makeSUT(remote: StubAuthRemote(userID: "user-42"), email: email, userID: userID, tokenStore: tokenStore)

        let session = try await sut.login(email: "user@example.com", password: "pw")

        #expect(session == Session(email: "user@example.com", userID: "user-42"))
        #expect(email.saved == "user@example.com")
        #expect(userID.saved == "user-42")
        #expect(tokenStore.token == "api-token-user-42") // ログイン成功でトークンが保存される
    }

    @Test("Given stored email and userID, when currentSession is called, then it returns the session")
    func restoresStoredSession() async {
        let sut = makeSUT(
            email: StubEmailStorage(saved: "user@example.com"),
            userID: StubUserIDStorage(saved: "user-9")
        )

        let session = await sut.currentSession()

        #expect(session == Session(email: "user@example.com", userID: "user-9"))
    }

    @Test("Given nothing stored, when currentSession is called, then it returns nil")
    func returnsNilWhenEmpty() async {
        let sut = makeSUT()

        let session = await sut.currentSession()

        #expect(session == nil)
    }
}
