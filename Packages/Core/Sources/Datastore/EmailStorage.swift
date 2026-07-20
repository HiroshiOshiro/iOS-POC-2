import Foundation

/// メールアドレスのローカル保存。
public protocol EmailStorage: Sendable {
    func save(_ email: String)
    func load() -> String?
}

/// UserDefaults にメールアドレスを保存する。
///
/// キーは他層に依存しないよう注入で受け取る。SwiftUI の `@AppStorage` と同じ
/// UserDefaults・同じキーを使えば、ここでの書き込みは View 側にそのまま反映される。
public final class UserDefaultsEmailStorage: EmailStorage, @unchecked Sendable {
    // UserDefaults はスレッドセーフのため @unchecked Sendable とする。
    private let defaults: UserDefaults
    private let key: String

    public init(key: String, defaults: UserDefaults = .standard) {
        self.key = key
        self.defaults = defaults
    }

    public func save(_ email: String) {
        defaults.set(email, forKey: key)
    }

    public func load() -> String? {
        defaults.string(forKey: key)
    }
}
