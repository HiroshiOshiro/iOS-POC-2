import Foundation

/// Todo 送信のリモートデータソース。
/// 他層に依存しないよう、モデルではなくプリミティブを受け取る。
/// NiA 相当: core:network の `NiaNetworkDataSource`（リモートデータソースの抽象）。
public protocol TodoRemoteDataSource: Sendable {
    func submit(text: String) async throws
}

/// Todo 送信で起きうるエラー。
public enum TodoRemoteError: Error {
    case submitFailed
}

/// 実際の通信は行わず、一定時間後に成功を返すフェイク実装。
/// NiA 相当: core:network の `DemoNiaNetworkDataSource`（デモ/フェイク実装）。
public struct FakeTodoRemoteDataSource: TodoRemoteDataSource {
    public init() {}

    public func submit(text: String) async throws {
        // ネットワーク遅延を模して 1 秒待つ。
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        // エラー処理のサンプル: テキストが "fail" のときは送信失敗を模す。
        if text.lowercased() == "fail" {
            throw TodoRemoteError.submitFailed
        }
    }
}
