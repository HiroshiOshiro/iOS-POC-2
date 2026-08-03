import Foundation

/// 複数の Swift モジュールで共通に使う文字列の公開アクセサ。
///
/// String Catalog はクロスモジュールの型安全シンボルを生成しないため、
/// 共有モジュール（Ui）の `.module` バンドルから引いた値を **public** で再公開する。
/// これで LoginImpl / ConfirmImpl など他モジュールから `L10n.hello` で使える。
public enum L10n {
    /// あいさつ（例: 各画面のヘッダに表示）。
    public static var hello: String {
        String(localized: "common.hello", bundle: .module)
    }
}
