import Foundation
import Model
import Data

/// 楽曲を検索するユースケース。
/// NiA 相当: core:domain の UseCase（例: `GetFollowableTopicsUseCase`）。
public protocol SearchMusicUseCase: Sendable {
    func execute(term: String) async throws -> [MusicTrack]
}

public struct DefaultSearchMusicUseCase: SearchMusicUseCase {
    private let repository: any MusicRepository

    public init(repository: any MusicRepository) {
        self.repository = repository
    }

    public func execute(term: String) async throws -> [MusicTrack] {
        try await repository.search(term: term)
    }
}
