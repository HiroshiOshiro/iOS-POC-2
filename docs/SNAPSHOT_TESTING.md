# スナップショットテスト運用メモ

主要画面の見た目を基準画像（PNG）で固定し、レイアウト/テーマの回帰を検知するための
**このプロジェクト固有の運用手順**。設計指針ではなく実行手順書。

> **どこから読むか**: 初めて触るなら「構成」→「導入手順」の順で読む。
> 既に導入済みで、日々テストを回す/基準を更新するだけなら「実行手順」から読めばよい。

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

### 基準画像の例

テストが実際に何を撮っているかの例（コミット済みの基準 PNG をそのまま表示。クリックで原寸）。

<table>
<tr>
<th>Login（既定）</th>
<th>Music（空）</th>
<th>Todo（空・ObjC/UIKit）</th>
</tr>
<tr>
<td><a href="../Tests/Snapshot/__Snapshots__/ScreenSnapshotTests/loginScreen.light.png"><img src="../Tests/Snapshot/__Snapshots__/ScreenSnapshotTests/loginScreen.light.png" width="200"></a></td>
<td><a href="../Tests/Snapshot/__Snapshots__/ScreenSnapshotTests/musicListScreenEmpty.light.png"><img src="../Tests/Snapshot/__Snapshots__/ScreenSnapshotTests/musicListScreenEmpty.light.png" width="200"></a></td>
<td><a href="../Tests/Snapshot/__Snapshots__/ScreenSnapshotTests/todoInputScreenEmpty.light.png"><img src="../Tests/Snapshot/__Snapshots__/ScreenSnapshotTests/todoInputScreenEmpty.light.png" width="200"></a></td>
</tr>
</table>

他の基準画像はすべて `Tests/Snapshot/__Snapshots__/ScreenSnapshotTests/` にある
（light/dark 各画面分。ここに無いものは未対応）。

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
`SIMULATOR_NAME`。現状 `iPhone 17`）。ズレると、レイアウトは同じでも
**OS のレンダリング差**（フォント・アンチエイリアス等）で不一致になることがある
（微小差は `perceptualPrecision` で吸収するが、端末/OSを変えたら基準ごと再記録するのが安全）。

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

### 合否（ターミナル出力）

全部パスすると、各テストの `✔` と末尾の `** TEST SUCCEEDED **` が出る：

```
✔ Test "Login screen — default (light / dark)" passed after 0.141 seconds.
✔ Test "Music list — populated (light / dark)" passed after 0.997 seconds.
✔ Suite ScreenSnapshotTests passed after 2.167 seconds.
** TEST SUCCEEDED **
```

不一致があると `✘` と `does not match reference.`、末尾は `** TEST FAILED **` になる：

```
✘ Test "Login screen — default (light / dark)" recorded an issue at ScreenSnapshotTests.swift:36:23: Issue recorded
↳ Snapshot "light" does not match reference.
  The percentage of pixels that match 0.9983034 is less than required 1.0
✘ Test "Login screen — default (light / dark)" failed after 1.165 seconds with 2 issues.
** TEST FAILED **
```

### 差分の中身を見る

失敗時、参照（reference）・実測（failure）・差分（difference）の PNG が生成される。
CLI では `-resultBundlePath` を付けて実行し、`.xcresult` から書き出すと画像として取り出せる：

```
xcodebuild test -project iOS-POC-2.xcodeproj -scheme iOS-POC-2 \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:iOS-POC-2Tests/ScreenSnapshotTests CODE_SIGNING_ALLOWED=NO \
  -resultBundlePath /tmp/snap.xcresult
```

```
xcrun xcresulttool export attachments --path /tmp/snap.xcresult --output-path /tmp/snap_attach
```

書き出し先の `manifest.json` に「テスト名 → 添付ファイル名」の対応が入っているので、
`difference_*.png` を探して開けば差分が見える。

GUI なら、実行後に生成された `.xcresult`（または Xcode のテストナビゲータの失敗テスト）を開き、
添付（reference / failure / difference の各 PNG）をそのままプレビューできる。

### 基準画像そのもの

`Tests/Snapshot/__Snapshots__/ScreenSnapshotTests/` の PNG を直接開く（「構成」の表の画像も同じもの）。

### Xcode GUI で回す場合

対象スキームで **⌘U**（該当テストのみ実行も可、テストナビゲータの ◇ をクリック）。

## つまずきどころ（このリポジトリ固有）

原因と対処は「導入手順 §2」で説明済み。ここでは**症状から逆引き**できるようにする。

| 症状（エラーメッセージ） | 原因 | 対処 |
|---|---|---|
| `project.yml` を変えたのに反映されない | `.xcodeproj` は生成物 | `xcodegen generate` を実行する |
| `os_object`/WebKit の PCM ビルド失敗 | 明示モジュールが有効 | 導入手順§2の `SWIFT_ENABLE_EXPLICIT_MODULES: NO` を確認 |
| `Build input file cannot be found`（PNG） | PNG がビルド入力に取り込まれている | 導入手順§2の `excludes` 設定を確認。それでも起きたら `xcodegen generate` |
| `Network.h` 系のビルド失敗 | 自作モジュール名がシステムフレームワークと衝突（例: `Network`） | 衝突しない名前にリネーム（本プロジェクトは `Networking`） |
| 上記の衝突/欠落エラーが**設定を直したのに**まだ出る | 古いビルド生成物が残っている | DerivedData をクリーンして再実行 |
| Keychain 系テストが `-34018` で失敗 | 署名なし（`CODE_SIGNING_ALLOWED=NO`）で entitlement 不足 | スナップショットとは別問題。署名を有効にして実行すれば通る |
