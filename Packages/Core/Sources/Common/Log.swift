import Foundation

/// Debug ビルドのみ `[ファイルID:行] テキスト` を標準出力へ出す共通ログ関数。
///
/// どのモジュールからでも `import Common` して `log("...")` で呼べる。
/// `#if DEBUG` により release ではコード・文字列とも完全に除去される。
/// 内部の `print` は将来 `os.Logger` 等へ差し替え可能（呼び出し側は不変）。
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
    print("[\(file):\(line)] \(message())")
    #endif
}
