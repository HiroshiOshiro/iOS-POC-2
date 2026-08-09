# スナップショットテスト導入手順（project.yml が無いプロジェクト向け）

XcodeGen（`project.yml`）を使わず、`.xcodeproj` を直接編集・管理している既存プロジェクト
（多くの既存アプリ）に pointfreeco/swift-snapshot-testing を導入するための**一般的な手順**。

> このリポジトリ自身は `project.yml` を使っているため、この手順は不要（[SNAPSHOT_TESTING.md](SNAPSHOT_TESTING.md) を参照）。
> あちらの `project.yml` の設定は、ここでは Xcode の GUI 操作に読み替えている。

## 前提

- すべて Xcode 上の操作で完結する（`.pbxproj` を手で編集する場面は無い）。
- 画面名など具体的な型名は現れないので、`〈Screen〉` のような形で一般化して書く。

## 1. ライブラリ依存を追加

1. プロジェクトナビゲータでプロジェクト（青いアイコン）を選択
2. プロジェクト選択時の **Package Dependencies** タブ → **+**
3. URL に `https://github.com/pointfreeco/swift-snapshot-testing` を入力 → **Add Package**
4. 追加先ターゲットの選択で、**テストターゲットにだけ**チェックを入れる（アプリ本体には不要）

これで `.xcodeproj`（`project.pbxproj`）に依存が書き込まれ、`Package.resolved` も自動生成される。

## 2. 事前に必要なビルド設定

テストターゲットの **Build Settings** タブで設定する。

- **明示モジュール（Explicit Modules）を無効化する**: `Enable Explicit Module Builds`
  （`SWIFT_ENABLE_EXPLICIT_MODULES`）を検索して **No** に。

  これは pointfreeco/swift-snapshot-testing 導入時にしばしば起きる既知の問題への回避策。
  設定しないと、依存をたどった先で WebKit フレームワークの事前ビルドに失敗し、
  `module 'os_object' is needed but has not been provided` のようなビルドエラーになることが
  ある（ライブラリのバグではなく、Xcode 16 以降の明示モジュール機能側の相性問題）。
  遭遇してから直すより、導入時に先に倒しておくと手戻りが少ない。
- **基準画像（PNG）をアプリ/テストバンドルのリソースに含めない**: 記録した基準 PNG を
  Xcode プロジェクトへ追加するとき、対象ターゲットの **Target Membership のチェックを外す**
  （または、あとから Build Phases → **Copy Bundle Resources** で外す）。

  含めてしまうと、基準を記録し直すために PNG を消したときに `Build input file cannot be
  found` でビルドが壊れる（`.xcodeproj` 側にファイル参照が残ったままになるため）。
- **自作モジュール名がシステムフレームワークと衝突していないか確認する**: 依存グラフを
  たどった先で、`Network` 等のシステムフレームワーク名と同じ名前の自作モジュールがあると
  ビルドが壊れることがある。衝突していたら、衝突しない名前へリネームする。

## 3. テストを書く

撮影したい画面（`UIViewController` または SwiftUI の `View`）ごとに、テストターゲットへ
Swift のテストファイルを追加する（XCTest / Swift Testing どちらでもよい）。

撮影対象へのアクセス方法は主に3パターンある。

- **公開の生成窓口がある場合**: その窓口経由で画面（`UIViewController`）を作って撮る。
  内部の実装が非公開でも、公開窓口を通す限り `@testable` は不要。
- **内部の View/ViewController を直接使いたい場合**: `@testable import <対象モジュール>` で
  非公開の型へアクセスする。SwiftUI の `View` に状態を注入できる `init` があれば、
  その場で任意の状態を作って撮れる。
- **Objective-C の画面の場合**: テストターゲット用のブリッジヘッダ（Build Settings の
  `Objective-C Bridging Header` に新規ファイルを指定）を用意し、対象クラスのヘッダを
  `#import` すれば Swift のテストから直接生成できる。

```swift
import Testing
import SnapshotTesting
@testable import YourAppModule // 内部型に触る場合のみ

@Test
func exampleScreen() {
    let vc = /* 対象の UIViewController を生成 */

    assertSnapshot(
        of: vc,
        as: .image(
            on: .iPhone13,              // 端末サイズを固定（実機/シミュレータの実サイズに依存させない）
            perceptualPrecision: 0.98,  // 微小なレンダ差を許容
            traits: .init(userInterfaceStyle: .light)
        ),
        named: "light"
    )
}
```

決定論にするための一般的な注意点:

- 通信・DB など外部依存はスタブ/フェイクに差し替え、オフラインで固定内容が返るようにする。
- 起動時に非同期で読み込む画面は、`UIWindow` に載せて `viewWillAppear`/`onAppear` を発火させ、
  ロード完了を待ってから撮る。
- ローディングスピナーのようなアニメーションする表示や、アラートのように別レイヤーへ提示される
  表示は対象にしない（前者は撮るたびに絵が変わり基準と一致しない。後者は撮影対象の画像に
  写り込まない）。

## 4. 基準画像を記録する

初回実行（テストナビゲータで対象テストを実行、または ⌘U）で、基準画像が無ければ**自動で記録**
されて一旦 fail 扱いになる。記録された画像を目視確認し、もう一度実行してパスすれば確定。
記録された PNG は Git 管理下に置く（テストターゲットのリソースには含めないこと。上記「2.」参照）。

`project.yml` ベースの手順にある「プロジェクト再生成（`xcodegen generate`）」に相当する工程は
無い。GUI で設定した時点で `.xcodeproj` に反映済みなので、そのまま記録に進めばよい。

## 5. CI 連携

既存の CI（`xcodebuild test` を実行しているジョブ）がそのまま新しいテストも拾うので、
**新しい CI ジョブは基本的に不要**。唯一の必須事項は、**CI が使うシミュレータ端末/OS を、
基準画像を記録した端末/OS に揃える**こと。ズレるとレンダリング差で不一致になりやすい。

## この後の運用

実行のしかた・基準の貼り替えかた・差分の確認方法は、`project.yml` の有無に関係なく共通
（Xcode の Test Navigator / Report Navigator を使った操作がそのまま使える）。詳しくは
[SNAPSHOT_TESTING.md](SNAPSHOT_TESTING.md) の「実行手順」「結果の確認方法」を参照
（CLI コマンド例は、自分のプロジェクトの `-project`/`-scheme` に読み替える）。
