import FactoryKit

/// トークン保管庫の登録。
/// クロージャが ObjC も使う `TokenManager.shared`（プロセス唯一）を返すので相互運用が保たれる。
/// 返す実体が既に単一のため Factory 側の `.singleton` は不要（既定スコープで毎回 `.shared` が返る）。
/// 抽象 `any TokenStoring` として公開し、`@Injected(\.tokenManager)` で解決／テストではスタブへ差し替える。
public extension Container {
    var tokenManager: Factory<any TokenStoring> {
        // .singleton は付けない: クロージャが既にプロセス唯一の .shared を返すため no-op。
        // （repository 系は new するので .singleton が必須だが、ここは不要。）
        self { TokenManager.shared }
    }
}
