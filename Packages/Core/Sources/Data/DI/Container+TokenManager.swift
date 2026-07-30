import FactoryKit

/// トークン保管庫の登録。
/// 既定では ObjC が使う `TokenManager.shared` と同一インスタンスを返すので相互運用が保たれる。
/// 抽象 `any TokenStoring` として公開し、`@Injected(\.tokenManager)` で解決／テストではスタブへ差し替える。
public extension Container {
    var tokenManager: Factory<any TokenStoring> {
        self { TokenManager.shared }.singleton
    }
}
