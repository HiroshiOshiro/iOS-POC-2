import Foundation

/// iTunes Search API のレスポンス DTO。
/// NiA 相当: core:network の ネットワーク DTO（`NetworkNewsResource` 等）。
public struct ITunesSearchResponse: Decodable, Sendable {
    public let results: [ITunesTrackDTO]
}

/// iTunes Search API の 1 要素（JSON）に対応する DTO。
/// モデル（`MusicTrack`）への変換は Data 層が行う。
public struct ITunesTrackDTO: Decodable, Sendable {
    public let trackId: Int?
    public let trackName: String?
    public let artistName: String?
    public let collectionName: String?
    public let primaryGenreName: String?
    public let artworkUrl100: String?
    public let previewUrl: String?
    public let trackViewUrl: String?
    public let releaseDate: String?
    public let trackTimeMillis: Int?

    // JSON からのデコードに加え、テスト等で直接組み立てられるよう public init を明示する。
    public init(
        trackId: Int?,
        trackName: String?,
        artistName: String?,
        collectionName: String?,
        primaryGenreName: String?,
        artworkUrl100: String?,
        previewUrl: String?,
        trackViewUrl: String?,
        releaseDate: String?,
        trackTimeMillis: Int?
    ) {
        self.trackId = trackId
        self.trackName = trackName
        self.artistName = artistName
        self.collectionName = collectionName
        self.primaryGenreName = primaryGenreName
        self.artworkUrl100 = artworkUrl100
        self.previewUrl = previewUrl
        self.trackViewUrl = trackViewUrl
        self.releaseDate = releaseDate
        self.trackTimeMillis = trackTimeMillis
    }
}
