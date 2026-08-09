# スナップショットテスト運用メモ

主要画面の見た目を基準画像（PNG）で固定し、レイアウト/テーマの回帰を検知するための
**このプロジェクト固有の運用手順**。設計指針ではなく実行手順書。

## 構成

- ライブラリ: [pointfreeco/swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing)
- テスト: `Tests/Snapshot/ScreenSnapshotTests.swift`（アプリ test バンドル `iOS-POC-2Tests` に同居）
- 基準画像: `Tests/Snapshot/__Snapshots__/ScreenSnapshotTests/*.png`（**Git 管理**）
- 撮影対象: 公開窓口 `LoginScreenFactory` / `MusicScreenFactory` が返す `UIViewController`
- 決定論: 固定 `ViewImageConfig(.iPhone13)` ＋ `perceptualPrecision 0.98`、
  各画面の `#Preview` と同じ要領で Factory にスタブ UseCase を register してオフライン化

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
