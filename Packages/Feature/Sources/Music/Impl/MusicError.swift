import Foundation

/// Music 画面のユーザー向けエラー（`LocalizedError`）。
/// `Model.TransportFailure`（どの通信段で失敗したか）を表示文言へマップしたもの。
enum MusicError: LocalizedError {
    case offline
    case network
    case server
    case decoding
    case unknown

    var errorDescription: String? {
        switch self {
        case .offline:  return L("music.error.offline")
        case .network:  return L("music.error.network")
        case .server:   return L("music.error.server")
        case .decoding: return L("music.error.decoding")
        case .unknown:  return L("music.error_title")
        }
    }
}
