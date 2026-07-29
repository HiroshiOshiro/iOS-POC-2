// swift-tools-version: 6.2
import PackageDescription

// UI 層は既定の隔離を MainActor にする（SE-0466）。各画面/ViewModel/factory は明示 @MainActor 不要。
// 背景処理が必要な宣言は個別に `nonisolated` で opt-out する。Core は対象外（背景処理のため）。
let mainActorIsolation: [SwiftSetting] = [
    .defaultIsolation(MainActor.self),
]

let package = Package(
    name: "Feature",
    defaultLocalization: "ja",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "ConfirmApi", targets: ["ConfirmApi"]),
        .library(name: "ConfirmImpl", targets: ["ConfirmImpl"]),
        .library(name: "LoginImpl", targets: ["LoginImpl"]),
        .library(name: "MusicImpl", targets: ["MusicImpl"]),
    ],
    dependencies: [
        .package(path: "../Core"),
        // DI コンテナ。Core は非依存のままにし、コンポジションルートである Feature 側で使う。
        .package(url: "https://github.com/hmlongco/Factory.git", from: "3.3.2"),
    ],
    targets: [
        // DesignSystem: テーマ・共通 UI 部品（NiA の core:designsystem 相当）。
        .target(
            name: "DesignSystem",
            dependencies: [.product(name: "Common", package: "Core")],
            swiftSettings: mainActorIsolation
        ),

        // Confirm/Api: 確認フローが外へ公開するナビ契約（NiA の feature/<name>/api 相当）。
        // 実装はアプリ側（Coordinator）が担い、impl はこの契約に依存する。
        .target(
            name: "ConfirmApi",
            dependencies: [.product(name: "Common", package: "Core")],
            path: "Sources/Confirm/Api",
            swiftSettings: mainActorIsolation
        ),

        // Confirm/Impl: 確認フローの画面・ViewModel・生成窓口（NiA の feature/<name>/impl 相当）。
        .target(
            name: "ConfirmImpl",
            dependencies: [
                "ConfirmApi",
                "DesignSystem",
                .product(name: "Common", package: "Core"),
                .product(name: "Domain", package: "Core"),
                .product(name: "Data", package: "Core"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
            path: "Sources/Confirm/Impl",
            resources: [
                .process("Resources")
            ],
            swiftSettings: mainActorIsolation
        ),

        // Login/Impl: ログインタブの画面・ViewModel・生成窓口。
        // 外へ公開するナビ契約が無いため api は持たない（NiA も nav 契約がある時のみ api を作る）。
        .target(
            name: "LoginImpl",
            dependencies: [
                "DesignSystem",
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
            ],
            swiftSettings: mainActorIsolation
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
            ],
            swiftSettings: mainActorIsolation
        ),

        // MARK: - Tests（iOS シミュレータで実行。ViewModel を @testable import で検証）
        // テストは MainActor 既定にしない（Sendable なスタブが nonisolated 前提のため）。

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
    ],
    swiftLanguageModes: [.v6]
)
