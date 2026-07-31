import SwiftUI

/// NiA 相当: core:designsystem の theme（`Color` / `NiaTheme`）。
public extension Color {
    /// アプリのブランドカラー。DesignSystem モジュールの Color Set "Brand"（ライト/ダーク対応）を参照する。
    /// ObjC 側は main バンドルの同名 Color Set を `[UIColor colorNamed:@"Brand"]` で引く（別バンドルのため各1個）。
    static let brand = Color("Brand", bundle: .module)
}
