import Foundation

/// Todo 送信のリモートデータソース。
/// 他層に依存しないよう、モデルではなくプリミティブを受け取る。
/// NiA 相当: core:network の `NiaNetworkDataSource`（リモートデータソースの抽象）。
public protocol TodoRemoteDataSource: Sendable {
    func submit(text: String) async
}

/// 実際の通信は行わず、一定時間後に成功を返すフェイク実装。
/// NiA 相当: core:network の `DemoNiaNetworkDataSource`（デモ/フェイク実装）。
public struct FakeTodoRemoteDataSource: TodoRemoteDataSource {
    public init() {}

    public func submit(text: String) async {
        // ネットワーク遅延を模して 1 秒待つ。
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
