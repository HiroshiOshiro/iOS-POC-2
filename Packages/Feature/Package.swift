// swift-tools-version: 6.0
import PackageDescription

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
    ],
    dependencies: [
        .package(path: "../Core"),
        // DI コンテナ。Core は非依存のままにし、コンポジションルートである Feature 側で使う。
        .package(url: "https://github.com/hmlongco/Factory.git", from: "3.3.2"),
    ],
    targets: [
        // DesignSystem: テーマ・共通 UI 部品（NiA の core:designsystem 相当）。
        .target(name: "DesignSystem"),

        // Confirm/Api: 確認フローが外へ公開するナビ契約（NiA の feature/<name>/api 相当）。
        // 実装はアプリ側（Coordinator）が担い、impl はこの契約に依存する。
        .target(
            name: "ConfirmApi",
            path: "Sources/Confirm/Api"
        ),

        // Confirm/Impl: 確認フローの画面・ViewModel・生成窓口（NiA の feature/<name>/impl 相当）。
        .target(
            name: "ConfirmImpl",
            dependencies: [
                "ConfirmApi",
                "DesignSystem",
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
                "DesignSystem",
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
    ]
)
