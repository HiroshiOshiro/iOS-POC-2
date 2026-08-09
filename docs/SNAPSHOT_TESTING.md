# スナップショットテスト運用メモ

主要画面の見た目を基準画像（PNG）で固定し、レイアウト/テーマの回帰を検知するための
**このプロジェクト固有の運用手順**。設計指針ではなく実行手順書。

## 構成

- ライブラリ: [pointfreeco/swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing)
- テスト: `Tests/Snapshot/ScreenSnapshotTests.swift`（アプリ test バンドル `iOS-POC-2Tests` に同居）
- 基準画像: `Tests/Snapshot/__Snapshots__/ScreenSnapshotTests/*.png`（**Git 管理**）
- 撮影対象（3 つのアクセス方法）:
  - **SwiftUI・公開 Factory**: `LoginScreenFactory` / `MusicScreenFactory` が返す `UIViewController`
  - **SwiftUI・内部 View**: `@testable import ConfirmImpl` で `Confirm1View` / `Confirm2View` を直接生成
  - **ObjC/UIKit**: テスト用ブリッジヘッダ経由で `TodoInputViewController` を生成
- 現状のカバレッジ（各 light/dark）: Login（既定 / セッション復元）, Music（一覧 / 空）,
  Confirm1, Confirm2, Todo 入力（空）
- 決定論: 固定 `ViewImageConfig(.iPhone13)` ＋ `perceptualPrecision 0.98`。各画面の `#Preview` と
  同じ要領で Factory にスタブ UseCase を register してオフライン化。onAppear 駆動の状態は
  ウィンドウに載せて非同期を待ってから撮る（`hostAndSettle`）

## 導入手順（ゼロから）

このプロジェクトに実際に導入したときの順序。既存の `iOS-POC-2Tests`（アプリ test バンドル）に
同居させることで、**新しいスキームや CI ジョブを増やさず**既存の `test:app` で回している。

### 1. ライブラリ依存を追加（`project.yml`）

`packages:` に追加：

```yaml
SnapshotTesting:
  url: https://github.com/pointfreeco/swift-snapshot-testing
  from: 1.17.0
```

`iOS-POC-2Tests` の `dependencies:` に、撮影に必要な分を追加：
`SnapshotTesting` 本体、対象画面の Feature モジュール（`LoginImpl` / `MusicImpl` / `ConfirmImpl` /
`ConfirmApi`）、スタブ登録用の `Domain` / `Model` / `Datastore` / `FactoryKit`。

### 2. 事前に必要なビルド設定（`project.yml`）

- **明示モジュールを無効化**（プロジェクト共通 `settings.base`）：
  `SWIFT_ENABLE_EXPLICIT_MODULES: NO`。無いと SnapshotTesting が WebKit を引く際に
  `os_object` / WebKit の PCM ビルドが失敗する。
- **基準 PNG をビルド入力から除外**（`iOS-POC-2Tests.sources`）：
  ```yaml
  sources:
    - path: Tests
      excludes:
        - "Snapshot/__Snapshots__/**"
  ```
  無いと PNG がリソースとして取り込まれ、記録貼り替えで PNG を消したとき
  `Build input file cannot be found` になる。
- **システムフレームワークと衝突するモジュール名を避ける**：自作 `Network` は Apple の
  `Network.framework` と衝突したため `Networking` にリネームした（衝突していると SnapshotTesting が
  AVFoundation/WebKit を引いた瞬間にビルドが壊れる）。

### 3. テストを書く（`Tests/Snapshot/ScreenSnapshotTests.swift`）

Swift Testing（`import Testing`）で `assertSnapshot` を呼ぶ。共通方針：
固定 `config`（`.iPhone13`）＋ `perceptualPrecision 0.98`、light/dark を `named:` で 2 枚、
`Container.shared` にスタブ UseCase を register してオフライン・固定内容にする。

対象の作り方は 3 パターン：

- **SwiftUI・公開 Factory**（例: Login/Music）: `LoginScreenFactory.makeLoginScreen()` を撮る。
  内部 View 非公開でも公開窓口経由なので `@testable` 不要。
- **SwiftUI・内部 View**（例: Confirm1/2）: `@testable import <Impl>` で内部 `View` を直接生成。
  `init(text:router:…)` があるので状態を注入でき、Router は no-op スタブを渡す。
- **ObjC/UIKit**（例: Todo）: **テスト用ブリッジヘッダ**を用意し `project.yml` に設定：
  ```yaml
  SWIFT_OBJC_BRIDGING_HEADER: Tests/iOS-POC-2Tests-Bridging-Header.h
  HEADER_SEARCH_PATHS:
    - "$(SRCROOT)/iOS-POC-2/Controllers"
  ```
  ブリッジヘッダに `#import "TodoInputViewController.h"` を書けば Swift テストから生成できる。

決定論のコツ：

- **onAppear で非同期ロードする画面**（Music/Todo/Login のセッション復元）は、VC を実ウィンドウに
  載せて `viewWillAppear`/`onAppear` を発火させ、ロード完了まで待ってから撮る（ヘルパ `hostAndSettle`）。
- **`AsyncImage`** はリモート取得で不安定になるので、スタブのデータで URL を `nil` にしてプレースホルダ固定。
- **スピナー（`ProgressView`）やエラー `alert` は撮らない**：前者はアニメーションで非決定論、後者は
  別コンテキスト提示で `UIHostingController` の画像に写らない。

### 4. プロジェクト再生成 → 基準記録

```
xcodegen generate
```

その後は下記「実行手順」の記録フロー（初回は自動記録で fail → 目視 → 再実行でパス確定）で
基準 PNG を作り、コミットする。

### 5. CI 連携

追加ジョブは不要（`.gitlab-ci.yml` の `test:app` がそのまま実行する）。
**`SIMULATOR_NAME` を、基準画像を記録した端末/OS に合わせる**ことだけ必須（現状 `iPhone 17`）。

## 実行手順

CI の `test:app` がそのまま実行するため、ローカルでも同じ `xcodebuild test` で回す。
**基準記録時と CI 実行は同じシミュレータ端末/OS に揃える**こと（`.gitlab-ci.yml` の
`SIMULATOR_NAME`。現状 `iPhone 17`）。

### 1. 実行（既存の基準と照合）

```
xcodebuild test -project iOS-POC-2.xcodeproj -scheme iOS-POC-2 \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:iOS-POC-2Tests/ScreenSnapshotTests CODE_SIGNING_ALLOWED=NO
```

- `-only-testing` は**スイート単位**（`.../ScreenSnapshotTests`）で指定する。
  Swift Testing のため、関数名までの指定（`.../ScreenSnapshotTests/loginScreen`）は
  マッチせず「0 tests」になる。

### 2. 初回・新規画面の基準記録

基準 PNG が無い状態で実行すると、**自動で記録して “fail” 扱い**になる
（`No reference was found on disk. Automatically recorded snapshot`）。
記録された PNG を目視確認 → もう一度 1. を実行してパスすれば確定。

### 3. 意図した UI 変更で基準を貼り替える

見た目を意図的に変えたら基準を更新する。いずれかの方法で再記録 → 目視 → コミット。

```
# 方法A: 環境変数で全再記録
SNAPSHOT_TESTING_RECORD=all xcodebuild test -project iOS-POC-2.xcodeproj -scheme iOS-POC-2 \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:iOS-POC-2Tests/ScreenSnapshotTests CODE_SIGNING_ALLOWED=NO
```

```
# 方法B: 対象の基準 PNG を消してから 1. を実行（消した分だけ再記録される）
rm Tests/Snapshot/__Snapshots__/ScreenSnapshotTests/musicListScreen.*.png
```

## 結果の確認方法

- **合否**: コマンド末尾の `** TEST SUCCEEDED **` / `** TEST FAILED **`、および
  各テストの `✔ / ✘`。差分時は `Snapshot "light" does not match reference.` が出る。
- **差分画像**: 失敗時、参照・実測・差分の PNG が一時ディレクトリに出力され、
  ログ／`.xcresult` から辿れる。GUI なら生成された `.xcresult` を Xcode で開くと添付画像を確認できる。
- **基準画像そのもの**: `Tests/Snapshot/__Snapshots__/ScreenSnapshotTests/` の PNG を直接開く。
- Xcode GUI で回す場合は対象スキームで **⌘U**（該当テストのみ実行も可）。

## つまずきどころ（このリポジトリ固有）

- **`project.yml` を変えたら `xcodegen generate`**。パッケージ・依存・ビルド設定の変更は
  再生成しないと `.xcodeproj` に反映されない（コードの中身変更だけなら不要）。
- **明示モジュール無効化が必須**。`project.yml` の `SWIFT_ENABLE_EXPLICIT_MODULES: NO` を外すと、
  SnapshotTesting が WebKit を引く際に `os_object`/WebKit の PCM ビルドが失敗する。
- **基準 PNG はビルド入力から除外済み**。`project.yml` の `iOS-POC-2Tests` で
  `Snapshot/__Snapshots__/**` を `excludes` している。これが無いと XcodeGen が PNG を
  リソースとして取り込み、記録貼り替えで PNG を消したとき
  `Build input file cannot be found` になる（消したら `xcodegen generate` が必要になる）。
- **モジュール名 `Network` は使わない**。Apple の `Network.framework` と衝突するため
  `Networking` にリネーム済み。同様に**システムフレームワーク名と被る自作モジュール名は避ける**。
- **古いビルド生成物で誤った衝突エラーが出たら DerivedData をクリーン**して再実行する。
- Keychain 系テスト（`iOS-POC-2Tests` 同居）は署名が要る。`CODE_SIGNING_ALLOWED=NO` だと
  `-34018` で落ちるが、これはスナップショットとは別問題。

## 端末/OS 差への注意

スナップショットは端末サイズを `ViewImageConfig` で固定しているが、**OS のレンダリング差**
（フォント・アンチエイリアス等）は残る。基準記録と実行を同一シミュレータに揃え、
微小差は `perceptualPrecision` で吸収する。CI ランナーの端末/OS が変わったら基準を再記録する。
