// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Feature",
    defaultLocalization: "ja",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "ConfirmApi", targets: ["ConfirmApi"]),
        .library(name: "ConfirmImpl", targets: ["ConfirmImpl"]),
        .library(name: "LoginImpl", targets: ["LoginImpl"]),
        .library(name: "MusicImpl", targets: ["MusicImpl"]),
    ],
    dependencies: [
        .package(path: "../Core"),
        // 共通 UI（テーマ・部品）。パッケージ名 Design、import 名は `Ui`。
        .package(path: "../Design"),
        // DI コンテナ。Core は非依存のままにし、コンポジションルートである Feature 側で使う。
        .package(url: "https://github.com/hmlongco/Factory.git", from: "3.3.2"),
        // 外部 SPM 依存を内部パッケージ経由に閉じ込めるラッパー。FeatureSnapshotTests から
        // SnapshotTesting を使うために依存する（外部URLはここには出てこない）。
        .package(path: "../DependencyManager"),
    ],
    targets: [
        // 共通 UI は独立パッケージ Design（import 名 `Ui`）。
        // 各 impl は `.product(name: "Ui", package: "Design")` で参照する。

        // Confirm/Api: 確認フローが外へ公開するナビ契約（NiA の feature/<name>/api 相当）。
        // 実装はアプリ側（Coordinator）が担い、impl はこの契約に依存する。
        .target(
            name: "ConfirmApi",
            dependencies: [.product(name: "Common", package: "Core")],
            path: "Sources/Confirm/Api"
        ),

        // Confirm/Impl: 確認フローの画面・ViewModel・生成窓口（NiA の feature/<name>/impl 相当）。
        .target(
            name: "ConfirmImpl",
            dependencies: [
                "ConfirmApi",
                .product(name: "Ui", package: "Design"),
                .product(name: "Common", package: "Core"),
                .product(name: "Domain", package: "Core"),
                .product(name: "Data", package: "Core"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
            path: "Sources/Confirm/Impl",
            resources: [
                .process("Resources")
            ]
        ),

        // Login/Impl: ログインタブの画面・ViewModel・生成窓口。
        // 外へ公開するナビ契約が無いため api は持たない（NiA も nav 契約がある時のみ api を作る）。
        .target(
            name: "LoginImpl",
            dependencies: [
                .product(name: "Ui", package: "Design"),
                .product(name: "Common", package: "Core"),
                .product(name: "Model", package: "Core"),
                .product(name: "Domain", package: "Core"),
                .product(name: "Data", package: "Core"),
                // @AppStorage が購読する保存キー（StorageKeys）を参照するため。
                .product(name: "Datastore", package: "Core"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
            path: "Sources/Login/Impl",
            resources: [
                .process("Resources")
            ]
        ),

        // Music/Impl: Music タブ（iTunes 検索の一覧→詳細）。外へのナビ契約が無いため api は持たない。
        .target(
            name: "MusicImpl",
            dependencies: [
                .product(name: "Model", package: "Core"),
                .product(name: "Domain", package: "Core"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
            path: "Sources/Music/Impl",
            resources: [
                .process("Resources")
            ]
        ),

        // MARK: - Tests（iOS シミュレータで実行。ViewModel を @testable import で検証）

        .testTarget(
            name: "FeatureTests",
            dependencies: [
                "LoginImpl",
                "ConfirmImpl",
                "ConfirmApi",
                .product(name: "Model", package: "Core"),
                .product(name: "Domain", package: "Core"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
            path: "Tests/FeatureTests"
        ),

        // スクリーンショットテスト。ObjC のまま残っている画面（アプリ本体ターゲット側）を除く、
        // パッケージ化済みの画面（Login/Music/Confirm）はここで撮る。
        .testTarget(
            name: "FeatureSnapshotTests",
            dependencies: [
                "LoginImpl",
                "MusicImpl",
                "ConfirmImpl",
                "ConfirmApi",
                .product(name: "Model", package: "Core"),
                .product(name: "Domain", package: "Core"),
                .product(name: "Datastore", package: "Core"),
                .product(name: "FactoryKit", package: "Factory"),
                .product(name: "SnapshotTestingSupport", package: "DependencyManager"),
                .product(name: "SnapshotTestHelpers", package: "DependencyManager"),
            ],
            path: "Tests/FeatureSnapshotTests",
            exclude: ["__Snapshots__"]
        ),
    ],
    // 言語モードを明示（tools 6.0 の既定と同じだが、意図を固定しアプリの SWIFT_VERSION 6.0 と揃える）。
    swiftLanguageModes: [.v6]
)
