import Foundation

/// Todo のローカル保存を抽象化したデータソース。
/// NiA 相当: core:database の DAO（`TopicDao`）。
nonisolated public protocol TodoLocalDataSource: Sendable {
    nonisolated func load() -> [TodoRecord]
    nonisolated func save(_ todos: [TodoRecord])
}
