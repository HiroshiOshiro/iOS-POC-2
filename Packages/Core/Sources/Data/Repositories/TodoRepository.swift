import Foundation
import Model
import Network
import Database

/// Todo の永続化を抽象化したリポジトリ。
/// NiA 相当: core:data の `TopicsRepository`（リポジトリ抽象）。
public protocol TodoRepository: Sendable {
    /// Todo を送信（フェイク API）し、ローカルへ保存する。
    func submit(_ todo: Todo) async
}

/// `TodoRepository` の実装。
/// リモート（フェイク API）送信のあとローカルへ保存する。読み書きを直列化するため actor とする。
/// NiA 相当: core:data の `OfflineFirstTopicsRepository`（リポジトリ実装）。
public actor DefaultTodoRepository: TodoRepository {
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
        await remote.submit(text: todo.text)
        // ローカル保存（新しい順で先頭へ挿入。既存 TodoStore と同じ挙動）
        var records = local.load()
        records.insert(TodoRecord(text: todo.text, createdAt: todo.createdAt), at: 0)
        local.save(records)
    }
}
