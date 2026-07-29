import Foundation

/// トークン保管庫の抽象。Swift 側（リポジトリ等）はこの protocol に依存し、
/// テストではスタブへ差し替えられるようにする。実体は `TokenManager`。
public protocol TokenStoring: AnyObject, Sendable {
    /// 現在のトークン（未設定なら nil）。
    var token: String? { get set }
    /// トークンを破棄する（ログアウト時など）。
    func clear()
}

/// API から取得したトークンをアプリ全体で共有する **インメモリ** の保管庫。
///
/// - 永続化しない（アプリ終了で消える）。
/// - ObjC からも読み書きするため、`actor` ではなく `NSObject` ＋ ロックにし、同期アクセスにする。
/// - ObjC は Factory を使えないので、共有入口は `@objc static let shared`。
///   （Swift は `@Injected(\.tokenManager)` でも同じインスタンスを取得できる。）
@objc public final class TokenManager: NSObject, TokenStoring, @unchecked Sendable {

    /// アプリ全体で共有する唯一のインスタンス（ObjC: `TokenManager.shared`）。
    @objc public static let shared = TokenManager()

    private let lock = NSLock()
    private var _token: String?

    private override init() { super.init() }

    /// 現在のトークン（未設定なら nil）。ロックでスレッドセーフに読み書きする。
    @objc public var token: String? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _token
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _token = newValue
        }
    }

    /// トークンを破棄する（ログアウト時など）。`token = nil` と同じだが意図を明示する。
    @objc public func clear() {
        lock.lock()
        defer { lock.unlock() }
        _token = nil
    }
}
