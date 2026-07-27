import Foundation
import Common

/// iTunes Search API のレスポンス DTO。
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
}

/// 楽曲検索のリモートデータソース。
/// NiA 相当: core:network の `NiaNetworkDataSource`（リモートデータソースの抽象）。
public protocol MusicRemoteDataSource: Sendable {
    func search(term: String) async throws -> [ITunesTrackDTO]
}

/// 楽曲検索で起きうるエラー。
public enum MusicRemoteError: Error {
    case invalidURL
    case httpStatus(Int)
}

/// iTunes Search API（キー不要）を `URLSession` で叩く実装。
/// NiA 相当: core:network の Retrofit 実装（`RetrofitNiaNetwork`）。
public struct ITunesMusicRemoteDataSource: MusicRemoteDataSource {
    public init() {}

    public func search(term: String) async throws -> [ITunesTrackDTO] {
        var components = URLComponents(string: "https://itunes.apple.com/search")
        components?.queryItems = [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "country", value: "JP"),
            URLQueryItem(name: "lang", value: "ja_jp"),
            URLQueryItem(name: "media", value: "music"),
            URLQueryItem(name: "entity", value: "song"),
            URLQueryItem(name: "limit", value: "50"),
        ]
        guard let url = components?.url else { throw MusicRemoteError.invalidURL }

        log("▶ Request GET \(url.absoluteString)")
        let start = Date()
        let (data, response) = try await URLSession.shared.data(from: url)
        let elapsedMs = Int(Date().timeIntervalSince(start) * 1000)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        log("◀ Response \(status) (\(elapsedMs) ms, \(data.count) bytes)")

        guard (200..<300).contains(status) else { throw MusicRemoteError.httpStatus(status) }

        let decoded = try JSONDecoder().decode(ITunesSearchResponse.self, from: data)
        return decoded.results
    }
}
