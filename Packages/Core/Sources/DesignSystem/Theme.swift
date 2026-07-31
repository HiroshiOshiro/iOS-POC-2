import SwiftUI

/// アプリのカラーテーマ（ハイブリッド構成）。
/// NiA 相当: core:designsystem の theme（`Color` / `NiaTheme`）。
///
/// - **パレット**（色そのもの）は Asset Catalog の Color Set（ライト/ダーク対応）に置く。
///   → 生成シンボル `Color(.paletteIndigo)` 等（module 内部）。
/// - **意味的な役割**（brand / navBar / …）はこのコード層でパレットへマップして公開する。
///   → 複数の役割が同じパレット色を指しても値を重複させずに済む（Color Set 同士は参照できないため）。
///
/// ObjC 側は main バンドルにパレットの一部（PaletteTeal）を持ち、
/// 役割マップは `AppAppearance`（ObjC のコード層）が担う。
public extension Color {

    // MARK: - 意味的な役割（役割 → パレット）

    /// ブランドカラー（アイコン・アクセント等）。
    static let brand = Color(.paletteIndigo)

    /// ナビゲーションバー背景色（各画面のカスタムナビバー）。
    static let navBar = Color(.paletteTeal)

    /// ログインボタン背景色。
    static let loginButton = Color(.paletteViolet)
}
