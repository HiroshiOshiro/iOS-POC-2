import FactoryKit

/// トークン保管庫の登録。
/// ObjC が使う `TokenManager.shared` と同一インスタンスを指すよう `.shared` を返す（`.singleton` でも同値）。
/// リポジトリへは `TokenStoring` 抽象として注入し（Container+Repository）、テストではスタブへ差し替える。
public extension Container {
    var tokenManager: Factory<TokenManager> {
        self { TokenManager.shared }.singleton
    }
}
