import Foundation

/// Todo のローカル保存を抽象化したデータソース。
/// NiA 相当: core:database の DAO（`TopicDao`）。
public protocol TodoLocalDataSource: Sendable {
    func load() -> [TodoRecord]
    func save(_ todos: [TodoRecord])
}
