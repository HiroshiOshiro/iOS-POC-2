import Foundation

/// テスト用の `URLProtocol`。`responder` に差し込んだクロージャで、
/// 実ネットワークを使わずに任意のレスポンス／エラーを返す。
///
/// `ITunesMusicRemoteDataSource(session:)` に、この protocol を仕込んだ
/// `URLSession` を注入して使う。
final class MockURLProtocol: URLProtocol {

    /// 受け取ったリクエストに対して (HTTPレスポンス, ボディ) を返すか、throw する。
    /// URLSession が任意スレッドで本 protocol を生成するため static + unsafe とし、
    /// 利用側の Suite は `.serialized` で直列化して競合を避ける。
    nonisolated(unsafe) static var responder: (@Sendable (URLRequest) throws -> (HTTPURLResponse, Data))?

    /// 直近に到達したリクエスト（URL 組み立ての検証用）。
    nonisolated(unsafe) static private(set) var lastRequest: URLRequest?

    static func reset() {
        responder = nil
        lastRequest = nil
    }

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.lastRequest = request
        guard let responder = Self.responder else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        do {
            let (response, data) = try responder(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

/// `MockURLProtocol` を仕込んだ隔離セッションを作る。
func makeMockedSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: config)
}
