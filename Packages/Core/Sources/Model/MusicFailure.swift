import Foundation

/// 楽曲検索の **どこで失敗したか** を表すカテゴリエラー。
///
/// `LoginFailure` と同様、層をまたぐ契約なので UI 非依存の Model に置く
/// （Data が投げ、Feature が受ける。MusicImpl は Data に依存しないため Model が唯一の共有点）。
/// - `offline`: 通信前チェックで端末が到達不能（＝そもそも通信できない）
/// - `network`: 通信を試みたが失敗（タイムアウト等）
/// - `server`: サーバーが非 2xx を返した（`status` は HTTP ステータス）
/// - `decoding`: レスポンスの解析（デコード）に失敗
public enum MusicFailure: Error, Sendable, Equatable {
    case offline
    case network
    case server(status: Int)
    case decoding
}
