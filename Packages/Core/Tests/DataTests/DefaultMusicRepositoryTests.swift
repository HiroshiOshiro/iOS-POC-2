import Testing
import Foundation
import FactoryKit
import Model
import Networking
@testable import Data

/// `DefaultMusicRepository` の DTO→モデル変換・フィルタリング・段別エラー変換を検証する。
/// @Injected は Container.shared から解決するため、スタブは register で差し替える（直列実行）。
@Suite(.serialized)
struct DefaultMusicRepositoryTests {

    private func makeSUT(dtos: [ITunesTrackDTO]) -> DefaultMusicRepository {
        Container.shared.musicRemoteDataSource.register { StubMusicRemote(dtos: dtos) }
        Container.shared.networkMonitor.register { StubNetworkMonitor(isReachable: true) }
        return DefaultMusicRepository()
    }

    private func makeSUT(remoteError: Error) -> DefaultMusicRepository {
        Container.shared.musicRemoteDataSource.register { StubMusicRemote(errorToThrow: remoteError) }
        Container.shared.networkMonitor.register { StubNetworkMonitor(isReachable: true) }
        return DefaultMusicRepository()
    }

    // MARK: - 通信前チェック（到達性）

    @Test("Given the device is offline, when search, then it throws TransportFailure.offline without calling remote")
    func offlinePreCheckThrowsAndSkipsRemote() async {
        let remote = StubMusicRemote(dtos: [dto(trackId: 1)])
        Container.shared.musicRemoteDataSource.register { remote }
        Container.shared.networkMonitor.register { StubNetworkMonitor(isReachable: false) }
        let sut = DefaultMusicRepository()

        await #expect(throws: TransportFailure.offline) {
            _ = try await sut.search(term: "x")
        }
        #expect(remote.receivedTerm == nil) // 前チェックで弾かれ、リモートは呼ばれない
    }

    // MARK: - 段別エラーへのマッピング（どこで失敗したか → TransportFailure）

    @Test("Given a non-2xx status, when search, then it throws TransportFailure.server")
    func mapsHTTPStatusToServer() async {
        let sut = makeSUT(remoteError: MusicRemoteError.httpStatus(503))
        await #expect(throws: TransportFailure.server(status: 503)) {
            _ = try await sut.search(term: "x")
        }
    }

    @Test("Given a connection failure, when search, then it throws TransportFailure.network")
    func mapsURLErrorToNetwork() async {
        let sut = makeSUT(remoteError: URLError(.notConnectedToInternet))
        await #expect(throws: TransportFailure.network) {
            _ = try await sut.search(term: "x")
        }
    }

    @Test("Given a decoding failure, when search, then it throws TransportFailure.decoding")
    func mapsDecodingErrorToDecoding() async {
        let decodingError = DecodingError.dataCorrupted(
            .init(codingPath: [], debugDescription: "test")
        )
        let sut = makeSUT(remoteError: decodingError)
        await #expect(throws: TransportFailure.decoding) {
            _ = try await sut.search(term: "x")
        }
    }

    /// 任意項目を省略できるよう trackId 以外はデフォルト nil にした DTO ファクトリ。
    private func dto(
        trackId: Int?,
        trackName: String? = nil,
        artistName: String? = nil,
        trackTimeMillis: Int? = nil
    ) -> ITunesTrackDTO {
        ITunesTrackDTO(
            trackId: trackId,
            trackName: trackName,
            artistName: artistName,
            collectionName: nil,
            primaryGenreName: nil,
            artworkUrl100: nil,
            previewUrl: nil,
            trackViewUrl: nil,
            releaseDate: nil,
            trackTimeMillis: trackTimeMillis
        )
    }

    @Test("Given DTOs, when search is called, then each field is mapped onto the model")
    func mapsFields() async throws {
        let sut = makeSUT(dtos: [
            dto(trackId: 42, trackName: "Lemon", artistName: "米津玄師", trackTimeMillis: 255000)
        ])

        let tracks = try await sut.search(term: "米津玄師")

        #expect(tracks.count == 1)
        #expect(tracks[0].id == 42)
        #expect(tracks[0].trackName == "Lemon")
        #expect(tracks[0].artistName == "米津玄師")
        #expect(tracks[0].trackTimeMillis == 255000)
    }

    @Test("Given a DTO without trackId, when search is called, then it is filtered out")
    func filtersOutRowsWithoutTrackID() async throws {
        let sut = makeSUT(dtos: [
            dto(trackId: 1, trackName: "keep"),
            dto(trackId: nil, trackName: "drop"), // 曲以外 → 除外
            dto(trackId: 2, trackName: "keep2")
        ])

        let tracks = try await sut.search(term: "x")

        #expect(tracks.map(\.id) == [1, 2])
    }

    @Test("Given a DTO with nil trackTimeMillis, when search is called, then duration defaults to 0")
    func defaultsMissingDurationToZero() async throws {
        let sut = makeSUT(dtos: [dto(trackId: 1, trackTimeMillis: nil)])

        let tracks = try await sut.search(term: "x")

        #expect(tracks[0].trackTimeMillis == 0)
    }

    @Test("Given no DTOs, when search is called, then it returns an empty list")
    func returnsEmptyWhenNoResults() async throws {
        let sut = makeSUT(dtos: [])

        let tracks = try await sut.search(term: "x")

        #expect(tracks.isEmpty)
    }
}
