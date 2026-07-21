import Foundation

/// 確認フローのユーザー向けエラー。
///
/// `LocalizedError` に準拠し、エラー自身が表示文言（`errorDescription`）を持つ。
enum ConfirmError: LocalizedError {
    /// 保存（送信）に失敗した。
    case submitFailed

    var errorDescription: String? {
        switch self {
        case .submitFailed:
            return L("confirm2.error")
        }
    }
}
