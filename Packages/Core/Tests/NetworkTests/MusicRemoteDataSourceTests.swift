import Testing
import Foundation
@testable import Networking

/// iTunes Search API クライアント（`ITunesMusicRemoteDataSource`）を、
/// `URLProtocol` で実ネットワークを差し替えて検証する。
/// static な responder を共有するため直列化する。
@Suite(.serialized)
struct ITunesMusicRemoteDataSourceTests {

    /// 指定ステータス＋ボディを返す responder を仕込む。
    private func stub(status: Int = 200, json: String) {
        MockURLProtocol.responder = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: status,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data(json.utf8))
        }
    }

    @Test("Given a search term, when search is called, then it builds the iTunes URL with the expected query")
    func buildsRequestURL() async throws {
        MockURLProtocol.reset()
        stub(json: #"{"results":[]}"#)
        let sut = ITunesMusicRemoteDataSource(session: makeMockedSession())

        _ = try await sut.search(term: "米津玄師")

        let url = try #require(MockURLProtocol.lastRequest?.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        #expect(components.host == "itunes.apple.com")
        #expect(components.path == "/search")
        let items = Dictionary(
            uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value) }
        )
        #expect(items["term"] == "米津玄師")
        #expect(items["country"] == "JP")
        #expect(items["media"] == "music")
        #expect(items["entity"] == "song")
        #expect(items["limit"] == "50")
    }

    @Test("Given a 200 response, when search is called, then it decodes the results")
    func decodesResults() async throws {
        MockURLProtocol.reset()
        stub(json: """
        {"results":[
          {"trackId":1,"trackName":"Lemon","artistName":"米津玄師","trackTimeMillis":255000},
          {"trackId":2,"trackName":"Flamingo","artistName":"米津玄師"}
        ]}
        """)
        let sut = ITunesMusicRemoteDataSource(session: makeMockedSession())

        let dtos = try await sut.search(term: "米津玄師")

        #expect(dtos.count == 2)
        #expect(dtos[0].trackId == 1)
        #expect(dtos[0].trackName == "Lemon")
        #expect(dtos[0].trackTimeMillis == 255000)
        #expect(dtos[1].trackTimeMillis == nil) // 欠けている任意項目は nil
    }

    @Test("Given an empty results array, when search is called, then it returns an empty list")
    func decodesEmptyResults() async throws {
        MockURLProtocol.reset()
        stub(json: #"{"results":[]}"#)
        let sut = ITunesMusicRemoteDataSource(session: makeMockedSession())

        let dtos = try await sut.search(term: "zzzznomatch")

        #expect(dtos.isEmpty)
    }

    @Test("Given a non-2xx status, when search is called, then it throws httpStatus")
    func throwsOnHTTPError() async {
        MockURLProtocol.reset()
        stub(status: 503, json: "")
        let sut = ITunesMusicRemoteDataSource(session: makeMockedSession())

        await #expect(throws: MusicRemoteError.self) {
            _ = try await sut.search(term: "x")
        }
    }

    @Test("Given malformed JSON on a 200, when search is called, then it throws a decoding error")
    func throwsOnMalformedJSON() async {
        MockURLProtocol.reset()
        stub(json: "not-json")
        let sut = ITunesMusicRemoteDataSource(session: makeMockedSession())

        await #expect(throws: (any Error).self) {
            _ = try await sut.search(term: "x")
        }
    }
}
