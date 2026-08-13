import Foundation

/// ログイン画面のユーザー向けエラー。
///
/// `LocalizedError` に準拠し、エラー自身が表示文言（`errorDescription`）を持つ。
/// これにより View 側は `error.localizedDescription` を表示するだけでよく、
/// 文言をハードコードしない（Swift 推奨のエラー設計）。
/// `Domain.AuthError`（どこで失敗したか）を、画面表示（文言）へマップした表示用エラー。
/// `Equatable` は View 側で「ネットワークエラーのときだけリトライ button を出す」ような
/// 表示分岐（`error == .network`）に使う。
enum LoginError: LocalizedError, Equatable {
    case validation
    case encryption
    case network
    case persistence
    case accessDenied
    case unknown

    var errorDescription: String? {
        switch self {
        case .validation:   return L("login.error.validation")
        case .encryption:   return L("login.error.encryption")
        case .network:      return L("login.error.network")
        case .persistence:  return L("login.error.persistence")
        case .accessDenied: return L("login.error.access_denied")
        case .unknown:      return L("login.error")
        }
    }
}
