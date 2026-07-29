import Foundation
import Model
import Data

/// 楽曲を検索するユースケース。
/// NiA 相当: core:domain の UseCase（例: `GetFollowableTopicsUseCase`）。
nonisolated public protocol SearchMusicUseCase: Sendable {
    nonisolated func execute(term: String) async throws -> [MusicTrack]
}

nonisolated public struct DefaultSearchMusicUseCase: SearchMusicUseCase {
    private let repository: any MusicRepository

    public init(repository: any MusicRepository) {
        self.repository = repository
    }

    nonisolated public func execute(term: String) async throws -> [MusicTrack] {
        try await repository.search(term: term)
    }
}
