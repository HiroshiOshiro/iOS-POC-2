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

/// login が必ず指定エラーを投げるスタブ（Data→Domain のエラー変換検証用）。
final class ThrowingAuthRepository: AuthRepository, @unchecked Sendable {
    let error: Error
    init(error: Error) { self.error = error }
    func login(email: String, password: String) async throws -> Session { throw error }
    func currentSession() async -> Session? { nil }
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

    @Test("Given a blank email, when execute, then it throws AuthError.validation (before the repository)")
    func throwsValidationForBlankEmail() async {
        let sut = DefaultLoginUseCase(
            repository: StubAuthRepository(session: Session(email: "x", userID: "x"))
        )
        // 空白のみ → 入力チェックで弾かれ、Repository へ到達しない。
        await #expect(throws: AuthError.validation) {
            try await sut.execute(email: "   ", password: "pw")
        }
    }

    @Test("Given the repository throws AuthDataError.persistence, when execute, then it is converted to AuthError.persistence")
    func convertsDataErrorToDomainError() async {
        let sut = DefaultLoginUseCase(repository: ThrowingAuthRepository(error: AuthDataError.persistence))
        await #expect(throws: AuthError.persistence) {
            try await sut.execute(email: "user@example.com", password: "pw")
        }
    }

    @Test("Given the repository throws AuthDataError.transport, when execute, then the TransportFailure is carried over")
    func carriesTransportFailureThrough() async {
        let sut = DefaultLoginUseCase(repository: ThrowingAuthRepository(error: AuthDataError.transport(.server(status: 503))))
        await #expect(throws: AuthError.transport(.server(status: 503))) {
            try await sut.execute(email: "user@example.com", password: "pw")
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
