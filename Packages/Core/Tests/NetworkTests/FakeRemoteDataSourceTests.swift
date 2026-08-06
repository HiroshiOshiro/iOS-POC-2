import Testing
import Networking

/// フェイクのリモートデータソース（成功／サンプル用の失敗トリガー）の挙動を検証する。
struct FakeAuthRemoteDataSourceTests {

    @Test("Given a normal email, when login is called, then it returns a userID")
    func returnsUserIDOnSuccess() async throws {
        let sut = FakeAuthRemoteDataSource()
        let userID = try await sut.login(email: "user@example.com", password: "pw")
        #expect(userID.hasPrefix("user-"))
    }

    @Test("Given an email containing fail, when login is called, then it throws")
    func throwsOnFailSentinel() async {
        let sut = FakeAuthRemoteDataSource()
        await #expect(throws: AuthRemoteError.self) {
            try await sut.login(email: "fail@example.com", password: "pw")
        }
    }
}

struct FakeTodoRemoteDataSourceTests {

    @Test("Given normal text, when submit is called, then it does not throw")
    func succeedsOnNormalText() async throws {
        let sut = FakeTodoRemoteDataSource()
        try await sut.submit(text: "牛乳を買う")
    }

    @Test("Given the text fail, when submit is called, then it throws")
    func throwsOnFailSentinel() async {
        let sut = FakeTodoRemoteDataSource()
        await #expect(throws: TodoRemoteError.self) {
            try await sut.submit(text: "fail")
        }
    }
}
