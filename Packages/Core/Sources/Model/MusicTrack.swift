import Foundation

/// iTunes Search API の 1 曲を表すドメインモデル。
/// NiA 相当: core:model のモデル（`Topic` / `NewsResource`）。
public struct MusicTrack: Sendable, Equatable, Identifiable {
    public let id: Int
    public let trackName: String?
    public let artistName: String?
    public let collectionName: String?   // アルバム名
    public let primaryGenreName: String?
    public let artworkUrl100: String?    // 100x100 サムネ
    public let previewUrl: String?       // 30秒試聴 (m4a)
    public let trackViewUrl: String?     // iTunes ページ
    public let releaseDate: String?      // ISO8601 文字列
    public let trackTimeMillis: Int

    public init(
        id: Int,
        trackName: String?,
        artistName: String?,
        collectionName: String?,
        primaryGenreName: String?,
        artworkUrl100: String?,
        previewUrl: String?,
        trackViewUrl: String?,
        releaseDate: String?,
        trackTimeMillis: Int
    ) {
        self.id = id
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

    /// 高解像度アートワーク URL（100x100 を 600x600 に差し替え）。
    public var artworkUrlLarge: String? {
        guard let artworkUrl100, !artworkUrl100.isEmpty else { return nil }
        return artworkUrl100.replacingOccurrences(of: "100x100", with: "600x600")
    }

    /// リリース日を "yyyy-MM-dd" で返す（無ければ nil）。
    public var releaseDateText: String? {
        guard let releaseDate, releaseDate.count >= 10 else { return nil }
        return String(releaseDate.prefix(10))
    }

    /// 再生時間を "m:ss" で返す（無ければ nil）。
    public var durationText: String? {
        guard trackTimeMillis > 0 else { return nil }
        let totalSeconds = trackTimeMillis / 1000
        return "\(totalSeconds / 60):" + String(format: "%02d", totalSeconds % 60)
    }
}
