import Foundation

/// Music 画面のユーザー向けエラー（`LocalizedError`）。
enum MusicError: LocalizedError {
    case loadFailed

    var errorDescription: String? {
        switch self {
        case .loadFailed:
            return L("music.error_title")
        }
    }
}
