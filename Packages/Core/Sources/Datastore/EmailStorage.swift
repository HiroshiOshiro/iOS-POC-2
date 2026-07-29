import Foundation

/// メールアドレスのローカル保存。
/// NiA 相当: core:datastore の `NiaPreferencesDataSource`（設定値の保存）。
nonisolated public protocol EmailStorage: Sendable {
    nonisolated func save(_ email: String)
    nonisolated func load() -> String?
}

/// UserDefaults にメールアドレスを保存する。
///
/// キーは他層に依存しないよう注入で受け取る。SwiftUI の `@AppStorage` と同じ
/// UserDefaults・同じキーを使えば、ここでの書き込みは View 側にそのまま反映される。
nonisolated public final class UserDefaultsEmailStorage: EmailStorage, @unchecked Sendable {
    // UserDefaults はスレッドセーフのため @unchecked Sendable とする。
    private let defaults: UserDefaults
    private let key: String

    public init(key: String, defaults: UserDefaults = .standard) {
        self.key = key
        self.defaults = defaults
    }

    nonisolated public func save(_ email: String) {
        defaults.set(email, forKey: key)
    }

    nonisolated public func load() -> String? {
        defaults.string(forKey: key)
    }
}
