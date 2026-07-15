import Foundation
import Domain
import Network
import LocalStorage

/// `TodoRepository` の実装。
/// リモート（フェイク API）送信のあとローカルへ保存する。読み書きを直列化するため actor とする。
public actor TodoRepositoryImpl: TodoRepository {
    private let remote: any TodoRemoteDataSource
    private let local: any TodoLocalDataSource

    public init(
        remote: any TodoRemoteDataSource = FakeTodoRemoteDataSource(),
        local: any TodoLocalDataSource = UserDefaultsTodoDataSource()
    ) {
        self.remote = remote
        self.local = local
    }

    public func submit(_ todo: Todo) async {
        // フェイク API 送信
        await remote.submit(todo)
        // ローカル保存（新しい順で先頭へ挿入。既存 TodoStore と同じ挙動）
        var todos = local.load()
        todos.insert(todo, at: 0)
        local.save(todos)
    }
}
