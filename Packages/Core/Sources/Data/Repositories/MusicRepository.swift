import Foundation
import FactoryKit
import Common
import Model
import Network

/// 楽曲検索を抽象化したリポジトリ。
/// NiA 相当: core:data の `TopicsRepository`（リポジトリ抽象）。
public protocol MusicRepository: Sendable {
    /// 楽曲を検索してモデルの配列で返す。
    func search(term: String) async throws -> [MusicTrack]
}

/// `MusicRepository` の実装。リモート（iTunes API）で検索し、DTO をモデルへ変換する。
/// NiA 相当: core:data の `OfflineFirstTopicsRepository`（リポジトリ実装）。
public struct DefaultMusicRepository: MusicRepository {
    // 依存は Factory から直接注入する（@Injected）。テストは Container に register して差し替える。
    @Injected(\.musicRemoteDataSource) private var remote
    @Injected(\.networkMonitor) private var networkMonitor

    public init() {}

    public func search(term: String) async throws -> [MusicTrack] {
        // Music の失敗はすべて通信レイヤ（ドメイン固有の失敗が無い）ため、
        // 共有の TransportFailure を直接投げる。
        // 通信前チェック: 端末が到達不能ならリクエストせず offline を投げる。
        guard networkMonitor.isReachable else {
            throw TransportFailure.offline
        }
        let dtos: [ITunesTrackDTO]
        do {
            dtos = try await remote.search(term: term)
        } catch let error as MusicRemoteError {
            switch error {
            case .httpStatus(let code): throw TransportFailure.server(status: code)
            case .invalidURL:           throw TransportFailure.network
            }
        } catch is DecodingError {
            throw TransportFailure.decoding
        } catch {
            // URLError 等（オフライン/タイムアウト）。
            throw TransportFailure.network
        }
        // trackId が無い要素（曲以外）は除外する。
        return dtos.compactMap { dto in
            guard let id = dto.trackId else { return nil }
            return MusicTrack(
                id: id,
                trackName: dto.trackName,
                artistName: dto.artistName,
                collectionName: dto.collectionName,
                primaryGenreName: dto.primaryGenreName,
                artworkUrl100: dto.artworkUrl100,
                previewUrl: dto.previewUrl,
                trackViewUrl: dto.trackViewUrl,
                releaseDate: dto.releaseDate,
                trackTimeMillis: dto.trackTimeMillis ?? 0
            )
        }
    }
}
