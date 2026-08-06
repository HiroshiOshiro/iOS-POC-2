import Foundation

/// 通信レイヤ共通の失敗（どのドメインでも同じ意味を持つ横断的なエラー）。
///
/// ドメイン固有の失敗（入力チェック等）とは区別し、こちらは複数ドメインで共有する。
/// ドメイン固有の失敗も持つ場合は、その層のエラーが `case transport(TransportFailure)` で
/// これを内包する（例: `AuthDataError` / `AuthError`）。失敗が通信だけのドメインは、
/// これを直接投げてよい（例: Music）。
/// - `offline`: 通信前チェックで端末が到達不能
/// - `network`: 通信を試みたが失敗（タイムアウト等）
/// - `server`: サーバーが非 2xx を返した（`status` は HTTP ステータス）
/// - `decoding`: レスポンスの解析（デコード）に失敗
public enum TransportFailure: Error, Sendable, Equatable {
    case offline
    case network
    case server(status: Int)
    case decoding
}
