import Foundation
import Common

/// Todo 送信のリモートデータソース。
/// 他層に依存しないよう、モデルではなくプリミティブを受け取る。
/// NiA 相当: core:network の `NiaNetworkDataSource`（リモートデータソースの抽象）。
nonisolated public protocol TodoRemoteDataSource: Sendable {
    nonisolated func submit(text: String) async throws
}

/// Todo 送信で起きうるエラー。
nonisolated public enum TodoRemoteError: Error {
    case submitFailed
}

/// 実際の通信は行わず、一定時間後に成功を返すフェイク実装。
/// NiA 相当: core:network の `DemoNiaNetworkDataSource`（デモ/フェイク実装）。
nonisolated public struct FakeTodoRemoteDataSource: TodoRemoteDataSource {
    public init() {}

    nonisolated public func submit(text: String) async throws {
        log("▶ Request POST /todos text=\(text)")
        let start = Date()
        // ネットワーク遅延を模して 1 秒待つ。
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        let elapsedMs = Int(Date().timeIntervalSince(start) * 1000)
        // エラー処理のサンプル: テキストが "fail" のときは送信失敗を模す。
        if text.lowercased() == "fail" {
            log("◀ Response 500 POST /todos (\(elapsedMs) ms) submitFailed")
            throw TodoRemoteError.submitFailed
        }
        log("◀ Response 200 POST /todos (\(elapsedMs) ms)")
    }
}
