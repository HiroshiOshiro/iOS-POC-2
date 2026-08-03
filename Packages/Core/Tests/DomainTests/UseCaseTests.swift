import Testing
import Model
import Data
@testable import Domain

// UseCase はリポジトリへ委譲する薄い層。委譲されることをスタブリポジトリで検証する。

final class StubTodoRepository: TodoRepository, @unchecked Sendable {
    private(set) var submitted: [Todo] = []
    func submit(_ todo: Todo) async throws { submitted.append(todo) }
}

final class StubAuthRepository: AuthRepository, @unchecked Sendable {
    let session: Session
    init(session: Session) { self.session = session }
    func login(email: String, password: String) async throws -> Session { session }
    func currentSession() async -> Session? { session }
}

final class StubMusicRepository: MusicRepository, @unchecked Sendable {
    let tracks: [MusicTrack]
    private(set) var receivedTerm: String?
    init(tracks: [MusicTrack]) { self.tracks = tracks }
    func search(term: String) async throws -> [MusicTrack] {
        receivedTerm = term
        return tracks
    }
}

struct SubmitTodoUseCaseTests {
    @Test("Given execute, when called, then it delegates the text to the repository")
    func delegatesToRepository() async throws {
        let repository = StubTodoRepository()
        let sut = DefaultSubmitTodoUseCase(repository: repository)

        try await sut.execute(text: "牛乳を買う")

        #expect(repository.submitted.map(\.text) == ["牛乳を買う"])
    }
}

struct LoginUseCaseTests {
    @Test("Given execute, when called, then it returns the repository's session")
    func returnsRepositorySession() async throws {
        let expected = Session(email: "user@example.com", userID: "user-1")
        let sut = DefaultLoginUseCase(repository: StubAuthRepository(session: expected))

        let result = try await sut.execute(email: "user@example.com", password: "pw")

        #expect(result == expected)
    }

    @Test("Given a blank email, when execute, then it throws LoginFailure.validation (before the repository)")
    func throwsValidationForBlankEmail() async {
        let sut = DefaultLoginUseCase(
            repository: StubAuthRepository(session: Session(email: "x", userID: "x"))
        )
        // 空白のみ → 入力チェックで弾かれ、Repository へ到達しない。
        await #expect(throws: LoginFailure.validation) {
            try await sut.execute(email: "   ", password: "pw")
        }
    }
}

struct LoadSessionUseCaseTests {
    @Test("Given execute, when called, then it returns the repository's current session")
    func returnsCurrentSession() async {
        let expected = Session(email: "user@example.com", userID: "user-1")
        let sut = DefaultLoadSessionUseCase(repository: StubAuthRepository(session: expected))

        let result = await sut.execute()

        #expect(result == expected)
    }
}

struct SearchMusicUseCaseTests {
    @Test("Given execute, when called, then it delegates the term to the repository and returns its tracks")
    func delegatesToRepository() async throws {
        let expected = MusicTrack(
            id: 1, trackName: "Lemon", artistName: "米津玄師",
            collectionName: nil, primaryGenreName: nil, artworkUrl100: nil,
            previewUrl: nil, trackViewUrl: nil, releaseDate: nil, trackTimeMillis: 0
        )
        let repository = StubMusicRepository(tracks: [expected])
        let sut = DefaultSearchMusicUseCase(repository: repository)

        let result = try await sut.execute(term: "米津玄師")

        #expect(result == [expected])
        #expect(repository.receivedTerm == "米津玄師")
    }
}
