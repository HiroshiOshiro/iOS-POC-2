// swift-tools-version: 6.0
import PackageDescription

/// 外部 SPM 依存を「内部パッケージ経由」に閉じ込めるための薄いラッパー置き場。
///
/// アプリ本体プロジェクト（project.yml/.xcodeproj）に外部 URL を直接書けない環境
/// （社内ネットワーク制限など）を想定し、外部 URL はこのパッケージの `Package.swift` にのみ
/// 書く。アプリ本体・他パッケージはここが公開する製品（例: `SnapshotTestingSupport`）だけに
/// 依存すればよい。詳しくは docs/SNAPSHOT_TESTING_WITHOUT_PROJECT_YML.md を参照。
let package = Package(
    name: "DependencyManager",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "SnapshotTestingSupport", targets: ["SnapshotTestingSupport"]),
        // スナップショットテスト間で共通の小さな UIKit ヘルパー（hostAndSettle 等）。
        // アプリ本体側・Packages/Feature 側の両テストから使う（重複コピーを避けるため）。
        .library(name: "SnapshotTestHelpers", targets: ["SnapshotTestHelpers"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.19.4"),
    ],
    targets: [
        .target(
            name: "SnapshotTestingSupport",
            dependencies: [
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        ),
        .target(name: "SnapshotTestHelpers"),
    ],
    swiftLanguageModes: [.v6]
)
