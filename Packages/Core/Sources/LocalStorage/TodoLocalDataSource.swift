import Foundation
import Domain

/// Todo のローカル保存を抽象化したデータソース。
public protocol TodoLocalDataSource: Sendable {
    func load() -> [Todo]
    func save(_ todos: [Todo])
}
