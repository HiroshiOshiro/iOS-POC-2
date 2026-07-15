import Foundation

/// Feature パッケージ内のローカライズ文字列を引く（`Resources/ja.lproj/Localizable.strings`）。
func L(_ key: String.LocalizationValue) -> String {
    String(localized: key, bundle: .module)
}
