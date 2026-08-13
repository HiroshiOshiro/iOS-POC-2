import Foundation
import Model

/// Data 層（Repository）が投げる、認証まわりのデータ処理の失敗。
///
/// この層の語彙で「**どのデータ操作が失敗したか**」を表す。上位（Domain）へは
/// 生のまま漏らさず、UseCase が自層の `AuthError` へ**変換**して受け取る
/// （層をまたいでエラー型を伝播させない）。
/// 通信レイヤの失敗は、どのドメインでも同じ意味を持つ横断的失敗なので、
/// 共有の `TransportFailure` を内包する。
/// - `encryption`: パスワード暗号化に失敗
/// - `persistence`: 保存（Keychain 等）に失敗
/// - `transport`: 通信レイヤの失敗（共有 `TransportFailure`）
/// - `missingToken`: アクセス許可チェックに使うトークンが無い（通信を試みる前の前提条件）
public enum AuthDataError: Error, Sendable, Equatable {
    case encryption
    case persistence
    case transport(TransportFailure)
    case missingToken
}
