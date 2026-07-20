// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Feature",
    defaultLocalization: "ja",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "ConfirmFeatureApi", targets: ["ConfirmFeatureApi"]),
        .library(name: "ConfirmFeatureImpl", targets: ["ConfirmFeatureImpl"]),
        .library(name: "LoginFeatureImpl", targets: ["LoginFeatureImpl"]),
    ],
    dependencies: [
        .package(path: "../Core"),
        // DI コンテナ。Core は非依存のままにし、コンポジションルートである Feature 側で使う。
        .package(url: "https://github.com/hmlongco/Factory.git", from: "3.3.2"),
    ],
    targets: [
        // DesignSystem: テーマ・共通 UI 部品（NiA の core:designsystem 相当）。
        .target(name: "DesignSystem"),

        // ConfirmFeatureApi: 確認フローが外へ公開するナビ契約（NiA の feature:*:api 相当）。
        // 実装はアプリ側（Coordinator）が担い、impl はこの契約に依存する。
        .target(name: "ConfirmFeatureApi"),

        // ConfirmFeatureImpl: 確認フローの画面・ViewModel・生成窓口（NiA の feature:*:impl 相当）。
        .target(
            name: "ConfirmFeatureImpl",
            dependencies: [
                "ConfirmFeatureApi",
                "DesignSystem",
                .product(name: "Domain", package: "Core"),
                .product(name: "Data", package: "Core"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
            resources: [
                .process("Resources")
            ]
        ),

        // LoginFeatureImpl: ログインタブの画面・ViewModel・生成窓口。
        // 外へ公開するナビ契約が無いため api は持たない（NiA も nav 契約がある時のみ :api を作る）。
        .target(
            name: "LoginFeatureImpl",
            dependencies: [
                "DesignSystem",
                .product(name: "Model", package: "Core"),
                .product(name: "Domain", package: "Core"),
                .product(name: "Data", package: "Core"),
                // @AppStorage が購読する保存キー（StorageKeys）を参照するため。
                .product(name: "Datastore", package: "Core"),
                .product(name: "FactoryKit", package: "Factory"),
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
