import Foundation

/// Todo のローカル保存を抽象化したデータソース。
public protocol TodoLocalDataSource: Sendable {
    func load() -> [TodoRecord]
    func save(_ todos: [TodoRecord])
}
