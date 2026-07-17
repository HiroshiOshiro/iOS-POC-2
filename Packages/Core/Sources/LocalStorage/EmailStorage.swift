import Foundation
import Domain

/// メールアドレスのローカル保存。
public protocol EmailStorage: Sendable {
    func save(_ email: String)
    func load() -> String?
}

/// UserDefaults にメールアドレスを保存する。
///
/// SwiftUI の `@AppStorage(StorageKeys.loginEmail)` と同じ UserDefaults・同じキーを使うため、
/// ここでの書き込みは View 側の `@AppStorage` にそのまま反映される。
public final class UserDefaultsEmailStorage: EmailStorage, @unchecked Sendable {
    // UserDefaults はスレッドセーフのため @unchecked Sendable とする。
    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func save(_ email: String) {
        defaults.set(email, forKey: StorageKeys.loginEmail)
    }

    public func load() -> String? {
        defaults.string(forKey: StorageKeys.loginEmail)
    }
}
