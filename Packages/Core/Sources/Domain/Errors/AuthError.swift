import Foundation
import Model
import Data

/// Domain 層（UseCase）が投げる、認証ユースケースの失敗。
///
/// Data 層の `AuthDataError` を**自層の語彙へ変換**したものに、Domain 固有の
/// `validation`（入力チェック）を加えたもの。Presentation はこれを表示用エラーへマップする。
/// 変換により、Data の実装都合（型）が Presentation まで漏れない。
/// - `validation`: 入力チェック（Domain 固有。Data 層には対応する失敗が無い）
/// - `encryption` / `persistence`: Data 層の同名失敗を写した段
/// - `transport`: 通信レイヤの失敗（共有 `TransportFailure`）
/// - `unknown`: 想定外（未知の失敗の受け皿）
public enum AuthError: Error, Sendable, Equatable {
    case validation
    case encryption
    case persistence
    case transport(TransportFailure)
    case unknown

    /// Data 層の失敗を Domain 層の語彙へ変換する。
    init(dataError: AuthDataError) {
        switch dataError {
        case .encryption:             self = .encryption
        case .persistence:            self = .persistence
        case .transport(let failure): self = .transport(failure)
        }
    }
}
