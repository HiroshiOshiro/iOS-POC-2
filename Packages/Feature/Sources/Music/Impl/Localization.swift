import Foundation

/// このモジュールのローカライズ文字列を引く（`Resources/ja.lproj/Localizable.strings`）。
nonisolated func L(_ key: String.LocalizationValue) -> String {
    String(localized: key, bundle: .module)
}
