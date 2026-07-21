import Foundation

/// ログイン画面のユーザー向けエラー。
///
/// `LocalizedError` に準拠し、エラー自身が表示文言（`errorDescription`）を持つ。
/// これにより View 側は `error.localizedDescription` を表示するだけでよく、
/// 文言をハードコードしない（Swift 推奨のエラー設計）。
enum LoginError: LocalizedError {
    /// 認証に失敗した（原因の技術的なエラー種別は問わずユーザー向けにまとめる）。
    case failed

    var errorDescription: String? {
        switch self {
        case .failed:
            return L("login.error")
        }
    }
}
