import Testing
import Model
@testable import Data

struct DefaultAuthRepositoryTests {

    @Test("Given login, when it is called, then the password is encrypted before reaching the remote")
    func encryptsPasswordBeforeRemote() async throws {
        let remote = StubAuthRemote()
        let sut = DefaultAuthRepository(
            remote: remote,
            passwordEncryptor: StubPasswordEncryptor(),
            emailStorage: StubEmailStorage(),
            userIDStorage: StubUserIDStorage(),
            tokenManager: StubTokenStore()
        )

        _ = try await sut.login(email: "user@example.com", password: "secret")

        #expect(remote.receivedPassword == "ENC(secret)") // 生パスワードではない
    }

    @Test("Given login succeeds, when it is called, then email and userID are persisted, the token is stored, and a session is returned")
    func persistsAndReturnsSession() async throws {
        let email = StubEmailStorage()
        let userID = StubUserIDStorage()
        let tokenStore = StubTokenStore()
        let sut = DefaultAuthRepository(
            remote: StubAuthRemote(userID: "user-42"),
            passwordEncryptor: StubPasswordEncryptor(),
            emailStorage: email,
            userIDStorage: userID,
            tokenManager: tokenStore
        )

        let session = try await sut.login(email: "user@example.com", password: "pw")

        #expect(session == Session(email: "user@example.com", userID: "user-42"))
        #expect(email.saved == "user@example.com")
        #expect(userID.saved == "user-42")
        #expect(tokenStore.token == "api-token-user-42") // ログイン成功でトークンが保存される
    }

    @Test("Given stored email and userID, when currentSession is called, then it returns the session")
    func restoresStoredSession() async {
        let sut = DefaultAuthRepository(
            remote: StubAuthRemote(),
            passwordEncryptor: StubPasswordEncryptor(),
            emailStorage: StubEmailStorage(saved: "user@example.com"),
            userIDStorage: StubUserIDStorage(saved: "user-9"),
            tokenManager: StubTokenStore()
        )

        let session = await sut.currentSession()

        #expect(session == Session(email: "user@example.com", userID: "user-9"))
    }

    @Test("Given nothing stored, when currentSession is called, then it returns nil")
    func returnsNilWhenEmpty() async {
        let sut = DefaultAuthRepository(
            remote: StubAuthRemote(),
            passwordEncryptor: StubPasswordEncryptor(),
            emailStorage: StubEmailStorage(),
            userIDStorage: StubUserIDStorage(),
            tokenManager: StubTokenStore()
        )

        let session = await sut.currentSession()

        #expect(session == nil)
    }
}
