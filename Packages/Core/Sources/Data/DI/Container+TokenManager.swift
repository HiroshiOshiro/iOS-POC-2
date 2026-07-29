import FactoryKit

/// トークン保管庫の登録。
/// ObjC が使う `TokenManager.shared` と同一インスタンスを指すよう `.shared` を返す（`.singleton` でも同値）。
/// Swift 側は `@Injected(\.tokenManager)` で取得できる。
public extension Container {
    var tokenManager: Factory<TokenManager> {
        self { TokenManager.shared }.singleton
    }
}
