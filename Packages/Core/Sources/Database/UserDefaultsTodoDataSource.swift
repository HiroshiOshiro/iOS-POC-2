import Foundation

/// UserDefaults を使った Todo のローカルデータソース。
///
/// 既存の Objective-C 実装（`TodoStore`）と互換の形式で読み書きする:
/// キー `todo_items` に「`{ text: String, createdAt: Date }` の辞書の配列」を保存する。
/// これにより入力画面（ObjC）の一覧表示・削除と同じデータを共有できる。
/// NiA 相当: core:database の DAO 実装（Room が生成する `TopicDao` 実体）。
public final class UserDefaultsTodoDataSource: TodoLocalDataSource, @unchecked Sendable {
    // UserDefaults はスレッドセーフのため @unchecked Sendable とする。
    private let defaults: UserDefaults

    private enum Keys {
        static let items = "todo_items"
        static let text = "text"
        static let createdAt = "createdAt"
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func load() -> [TodoRecord] {
        guard let raw = defaults.array(forKey: Keys.items) as? [[String: Any]] else {
            return []
        }
        return raw.compactMap { dict in
            guard let text = dict[Keys.text] as? String else { return nil }
            let createdAt = dict[Keys.createdAt] as? Date ?? Date()
            return TodoRecord(text: text, createdAt: createdAt)
        }
    }

    public func save(_ todos: [TodoRecord]) {
        let raw: [[String: Any]] = todos.map { todo in
            [
                Keys.text: todo.text,
                Keys.createdAt: todo.createdAt,
            ]
        }
        defaults.set(raw, forKey: Keys.items)
    }
}
