import SwiftUI

/// NiA 相当: core:designsystem の theme（`Color` / `NiaTheme`）。
/// いずれも DesignSystem モジュールの Color Set（ライト/ダーク対応）を参照する。
public extension Color {
    /// アプリのブランドカラー（アイコン・アクセント等）。
    static let brand = Color("Brand", bundle: .module)

    /// ナビゲーションバー背景色（各画面のカスタムナビバー）。
    /// ObjC 側は main バンドルの同名 Color Set を `[UIColor colorNamed:@"NavBar"]` で引く（別バンドルのため各1個）。
    static let navBar = Color("NavBar", bundle: .module)

    /// ログインボタン背景色。
    static let loginButton = Color("LoginButton", bundle: .module)
}
