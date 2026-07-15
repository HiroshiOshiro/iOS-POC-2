# iOS-POC-2

Objective-C 製 iOS アプリへの **Swift 段階導入** を検証するための POC サンプルアプリ。

## アプリ設定

| 項目 | 内容 |
|---|---|
| 言語 | Objective-C |
| アーキテクチャ | MVC |
| OSサポート下限 | iOS 14.0 |
| UI | コードベース（ストーリーボードなし・Auto Layout） |
| 永続化 | `NSUserDefaults`（Android の SharedPreference 相当） |

## 機能

下部に 2 つのタブを持つ。

- **タブ①: Todo** — 以下 4 画面のフロー
  1. **入力画面** — テキストボックス＋保存ボタン。保存済み Todo を一覧表示し、横スワイプで削除。
  2. **確認画面①** — 入力内容を確認し「次へ」で遷移。
  3. **確認画面②** — 「保存」でフェイク API 呼び出し → `NSUserDefaults` へ保存 → 完了画面へ。
  4. **完了画面** — 「完了しました」メッセージ＋「入力に戻る」ボタン。
- **タブ②: Memo** — 空タブ。

## プロジェクト構成（MVC）

```
iOS-POC-2/
├── Models/       TodoItem, TodoStore（永続化）
├── Controllers/  MainTabBar / TodoInput / Confirm1 / Confirm2 / Completion / Memo
└── Services/     FakeAPIClient（保存を模したフェイクAPI）
```

## ビルド / 起動

```bash
open iOS-POC-2.xcodeproj
```

`.xcodeproj` は [XcodeGen](https://github.com/yonyz/XcodeGen) の `project.yml` から生成しています。設定を変更した場合は再生成してください。

```bash
xcodegen generate
```

## Swift 導入の準備

段階的な Swift 化に向けて、ビルド設定を先行して整えてあります。

- `SWIFT_VERSION` / `SWIFT_OBJC_BRIDGING_HEADER`（Swift → Objective-C 参照）
- `SWIFT_OBJC_INTERFACE_HEADER_NAME = iOS-POC-2-Swift.h`（Objective-C → Swift 参照）
- 空の Bridging Header を配置済み
