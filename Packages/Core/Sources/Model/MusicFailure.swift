import Foundation

/// 楽曲検索の **どこで失敗したか** を表すカテゴリエラー。
///
/// `LoginFailure` と同様、層をまたぐ契約なので UI 非依存の Model に置く
/// （Data が投げ、Feature が受ける。MusicImpl は Data に依存しないため Model が唯一の共有点）。
/// - `network`: 接続失敗（オフライン/タイムアウト等）
/// - `server`: サーバーが非 2xx を返した（`status` は HTTP ステータス）
/// - `decoding`: レスポンスの解析（デコード）に失敗
public enum MusicFailure: Error, Sendable, Equatable {
    case network
    case server(status: Int)
    case decoding
}
