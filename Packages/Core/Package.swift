// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "Network", targets: ["Network"]),
        .library(name: "LocalStorage", targets: ["LocalStorage"]),
        .library(name: "Data", targets: ["Data"]),
    ],
    targets: [
        // Domain: モデル・リポジトリ protocol・UseCase（純粋・依存なし）
        .target(name: "Domain"),
        // Network: リモートデータソース（フェイクAPI）
        .target(name: "Network", dependencies: ["Domain"]),
        // LocalStorage: UserDefaults ベースのローカルデータソース
        .target(name: "LocalStorage", dependencies: ["Domain"]),
        // Data: リポジトリ実装（Network 呼び出し → LocalStorage 保存）
        .target(name: "Data", dependencies: ["Domain", "Network", "LocalStorage"]),
    ]
)
