# リソース管理ガイドライン（画像・文字列・色）

対象環境: **ObjC + Swift 混在 / Swift 部分はマルチモジュール(SPM) / Swift 6 / iOS 16+**

このドキュメントは「あるべき姿（理想）」を第一原理から示す。現状の実装をそのまま正とはせず、
理想を提示したうえで **現状との差分（直すべき点）** も明記する。

---

## 1. 唯一の絶対制約: バンドル所有

すべての判断はこれで決まる。

- **ObjC** が読めるのは `Bundle.main`（アプリ本体）だけ。SPM モジュールのバンドルは読めない。
- **各 SPM モジュール** は自分専用の `.module` バンドルを持つ。
- **バンドルは跨がない**。モジュールが `.main` を参照するのは逆依存（アンチパターン）、
  ObjC がモジュールバンドルを読むのは不可能。

### 判断軸（フローチャート）

```
そのリソースを ObjC（= app ターゲット / main）が使う？
├─ YES → main バンドル（iOS-POC-2/Assets.xcassets, iOS-POC-2/Localizable.xcstrings）
└─ NO  → それを使う「モジュール」のバンドル（Packages/.../Resources/...）

参照方法:
  Swift → 型安全な生成シンボル（＋クロスモジュールなら public 公開層）
  ObjC  → 文字列参照（＋役割マップは ObjC のコード層）
```

### 帰結: 両方が使うリソースは「バンドルごとに複製」

ObjC とモジュールの**両方**が使う色/画像/文字列は、`main` と `.module` に**それぞれ 1 つずつ**
持つしかない（ハックで単一化はできない）。値の重複は各言語のコード層（Swift の `extension` /
ObjC の `AppAppearance` 等）で「役割 → リソース」をマップして吸収する。

> 例: ナビバー色はObjC(Todo)とSwiftUI(Login/Confirm)の両方で使う → `PaletteTeal` を
> `main` と `DesignSystem` の両カタログに置く。

---

## 2. 参照方法（言語別）

| | Swift | ObjC |
|---|---|---|
| 色 | `Color(.paletteTeal)`（生成シンボル） | `[UIColor colorNamed:@"PaletteTeal"]` |
| 画像 | `Image(.loginIllustration)` / `UIImage(resource:)` | `[UIImage imageNamed:@"todo"]` |
| 文字列 | `String(localized:)` / `L(_:)` | `NSLocalizedString(key, nil)` |

- **Swift の生成シンボルは module 内部(internal)**。他モジュール（や app）から使うには
  `public extension Color { static let navBar = Color(.paletteTeal) }` のように公開層で再公開する。
- **ObjC には生成シンボルが無い**。文字列キーで引き、役割の意味付けは ObjC のコード層に置く
  （例: `AppAppearance.navBarColor` が `colorNamed:@"PaletteTeal"` を返す）。

---

## 3. 種類別の指針

### 3.1 色 — Asset Catalog（Color Set）＋ハイブリッド

- **形式**: Asset Catalog の Color Set。**light/dark（＋必要なら high-contrast）を必ず定義**。
  コードの `Color(red:...)` 直書きは避ける（ダークモードの手当てが手動になる）。
- **ハイブリッド構成**（役割が増えてもスケールする）:
  - **パレット**（色そのもの: `PaletteIndigo` / `PaletteTeal` / …）を Asset Catalog に置く。
  - **意味的な役割**（`brand` / `navBar` / `loginButton`）を**コード層**でパレットへマップ。
    Color Set 同士は参照できないため、役割をコードで割り当てると値の重複を防げる。
- **公開**: Swift は `extension Color`（小規模）or `enum` 名前空間（役割が十数個超で `Color.`
  補完が汚れてきたら）。ObjC は `AppAppearance` で役割マップ。
- 実ファイル例: `Packages/Core/Sources/DesignSystem/Resources/Media.xcassets/PaletteTeal.colorset`,
  `Packages/Core/Sources/DesignSystem/Theme.swift`, `iOS-POC-2/Common/AppAppearance.m`。

### 3.2 画像 — Asset Catalog（Image Set）＋用途別

- **形式の優先順位**:
  1. **ベクタ（PDF / SVG, "Preserve Vector Data" ON）** — 多解像度・拡大に強い。第一候補。
  2. ラスタ（PNG）は **@1x/@2x/@3x** を用意（単一なら single-scale）。
  3. **システムアイコンは SF Symbols**（`Image(systemName:)` / `[UIImage systemImageNamed:]`）。
     アセット不要・自動で太さ/色が追従。
  4. **リモート画像は `AsyncImage`**。
- **置き場**: モジュール専用（例: ログインイラスト）→ モジュール、ObjC/共有（タブアイコン
  todo/music/login）→ main。
- 実ファイル例: `Packages/Feature/Sources/Login/Impl/Resources/Media.xcassets/LoginIllustration.imageset`,
  `iOS-POC-2/Assets.xcassets/{todo,music,login}.imageset`。

### 3.3 文字列 — String Catalog（.xcstrings）

- **形式**: String Catalog（.xcstrings）が最適。iOS16 / Swift6 / ObjC すべて対応し、ビルド時に
  `.strings`/`.stringsdict` へコンパイルされる（実行時のバンドル参照は従来と同一）。
- **置き場**: ObjC/app-target が使う → main（`iOS-POC-2/Localizable.xcstrings`）、モジュール専用
  → 各モジュールの `Resources/Localizable.xcstrings`。**1 キー 1 ホーム**（重複は翻訳ズレの元）。
- **型安全性の注意（Asset Catalog との重要な違い）**: String Catalog は **Swift の型安全シンボルを
  自動生成しない**（色/画像のような `Color(.x)` 相当が無い）。型安全・自動抽出・翻訳状態管理を
  活かすなら:
  - **call site をリテラルの `String(localized:"key")` / `NSLocalizedString(@"key", nil)` にする**
    → Xcode が自動抽出してカタログに反映・状態管理できる。
  - もしくは **SwiftGen** 等で型安全アクセサを生成する。
  - **`L(key)` のような「可変キーを取るランタイム薄ラッパ」を主手段にしない**。簡潔だが、
    Xcode から見るとキーが動的なので**自動抽出・型安全が効かない**（小規模なら許容）。

---

## 4. モジュール構成の注意

- **純ロジックの Core パッケージは、できるだけクロスプラットフォーム（macOS host）で
  `swift test` できる状態に保つのが理想**（高速なユニットテスト）。
- **UIKit 依存の DesignSystem（`Color(uiColor:)` 等）を Core に同居させると Core が iOS 専用に
  なり、host テストを失う**。理想は **DesignSystem を独立した UI レイヤのパッケージ**にして
  Core を汚さないこと。
- リソースの「家」を決めるときは、そのモジュールが**他モジュールに課すプラットフォーム制約**まで
  考える。

---

## 5. Swift 6 / SPM の実務ノート

- リソース参照は不変な値型で **Sendable 安全**（並行性の追加対応は不要）。
- `Bundle.module` はターゲットに `resources:` を宣言すると**自動生成**される。
- **SPM リソースバンドルの増分ビルド不具合**: モジュールにアセットを追加/改名しても、app に
  埋め込まれたモジュールバンドルへ**伝播しない**ことがある（古い `*.bundle` のまま＝画像が
  真っ白/色が出ない）。**clean build**（`xcodebuild clean` → `build`）で解消する。

---

## 6. 現状（このリポジトリ）vs 理想

| 項目 | 現状 | 理想との差分 |
|---|---|---|
| 色 | Asset Catalog＋ハイブリッド（パレット/役割）、light/dark、生成シンボル | ✅ 一致 |
| 画像（アイコン/イラスト） | Asset Catalog、生成シンボル、SF Symbols、AsyncImage | ✅ ほぼ一致。イラストがラスタ PNG → 原則は **vector 優先** |
| 文字列 | String Catalog ＋ モジュールは `L()` 薄ラッパ | ⚠️ `L()` は自動抽出/型安全を殺す → **リテラル `String(localized:)` か SwiftGen** に寄せる余地 |
| DesignSystem の置き場 | Core パッケージに同居（→ Core が iOS 専用、macOS host テストを廃止） | ⚠️ 理想は **独立 UI パッケージ**にして Core をクロスプラットフォームに保つ |

> 差分は「今すぐ直すべき不具合」ではなく、規模が育ったときに効いてくる改善候補。
