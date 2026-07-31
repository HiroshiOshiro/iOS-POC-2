import Foundation
import Common

// DTO（ITunesSearchResponse / ITunesTrackDTO）は Model/ITunesTrackDTO.swift に分離。

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
    private let session: URLSession

    /// 既定は共有セッション。テストでは `URLProtocol` を仕込んだセッションを注入する。
    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func search(term: String) async throws -> [ITunesTrackDTO] {
        var components = URLComponents(string: "https://itunes.apple.com/search")
        components?.queryItems = [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "country", value: "JP"),
            URLQueryItem(name: "lang", value: "ja_jp"),
            URLQueryItem(name: "media", value: "music"),
            URLQueryItem(name: "entity", value: "song"),
            URLQueryItem(name: "limit", value: "50")
        ]
        guard let url = components?.url else { throw MusicRemoteError.invalidURL }

        log("▶ Request GET \(url.absoluteString)")
        let start = Date()
        let (data, response) = try await session.data(from: url)
        let elapsedMs = Int(Date().timeIntervalSince(start) * 1000)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        log("◀ Response \(status) (\(elapsedMs) ms, \(data.count) bytes)")

        guard (200..<300).contains(status) else { throw MusicRemoteError.httpStatus(status) }

        let decoded = try JSONDecoder().decode(ITunesSearchResponse.self, from: data)
        return decoded.results
    }
}
