import Foundation

/// ログイン処理の **どの段階で失敗したか** を表すカテゴリエラー。
///
/// UI 文言は持たない（Model は UI 非依存）。表示は Feature 層で
/// `LoginFailure` → `LoginError`（`LocalizedError`）へマップして切り替える。
/// - `validation`: 入力チェック（UseCase）
/// - `encryption`: パスワード暗号化（Repository）
/// - `network`: 通信（Repository）
/// - `persistence`: 保存（Keychain 等, Repository）
public enum LoginFailure: Error, Sendable, Equatable {
    case validation
    case encryption
    case network
    case persistence
}
