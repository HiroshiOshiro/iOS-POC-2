import Foundation
import os

/// アプリ共通の `Logger`（subsystem＝バンドルID、category＝任意）。
/// Console.app や `log stream` で subsystem/category による絞り込みができる。
private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "iOS-POC-2",
    category: "app"
)

/// Debug ビルドのみ `[ファイルID:行] テキスト` を統合ログ（os.Logger）へ出す共通ログ関数。
///
/// どのモジュールからでも `import Common` して `log("...")` で呼べる。
/// `#if DEBUG` により release ではコード・文字列とも完全に除去される。
/// 出力は Xcode コンソール／Console.app／`log stream` で確認できる（stdout ではない）。
/// NiA 相当: core:common のユーティリティ。
///
/// - Parameters:
///   - message: 出力するテキスト（`@autoclosure` なので release では評価もされない）。
///   - file: 呼び出し元ファイル（`#fileID` = 「Module/File.swift」形式）。
///   - line: 呼び出し元の行番号。
public func log(
    _ message: @autoclosure () -> String,
    file: String = #fileID,
    line: Int = #line
) {
    #if DEBUG
    // message() を先に確定させる（os.Logger の補間はエスケープするため非エスケープ引数を直接渡せない）。
    let text = message()
    // os.Logger は動的値を既定でマスクするため、開発用ログとして .public を明示する。
    logger.debug("[\(file, privacy: .public):\(line, privacy: .public)] \(text, privacy: .public)")
    #endif
}
