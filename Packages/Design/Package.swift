// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Design",
    defaultLocalization: "ja",
    platforms: [
        // UIKit 依存（`Color(uiColor:)` 等）のため iOS 専用。
        .iOS(.v16),
    ],
    products: [
        // テーマ・共通 UI 部品（NiA の core:designsystem 相当）。import 名は `Ui`。
        .library(name: "Ui", targets: ["Ui"]),
    ],
    dependencies: [
        // 横断ユーティリティ（ログ等）を Core の Common から借りる。
        .package(path: "../Core"),
    ],
    targets: [
        .target(
            name: "Ui",
            dependencies: [.product(name: "Common", package: "Core")],
            path: "Sources/Ui",
            resources: [.process("Resources")]
        ),
    ],
    swiftLanguageModes: [.v6]
)
