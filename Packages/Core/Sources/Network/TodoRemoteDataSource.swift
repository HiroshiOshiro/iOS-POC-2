import Foundation
import Domain

/// Todo 送信のリモートデータソース。
public protocol TodoRemoteDataSource: Sendable {
    func submit(_ todo: Todo) async
}

/// 実際の通信は行わず、一定時間後に成功を返すフェイク実装。
public struct FakeTodoRemoteDataSource: TodoRemoteDataSource {
    public init() {}

    public func submit(_ todo: Todo) async {
        // ネットワーク遅延を模して 1 秒待つ。
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }
}
