// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS(.v15),
        // macOS はホスト上での `swift build` による単体ビルド検証用（アプリは iOS のみ）。
        .macOS(.v12),
    ],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "Network", targets: ["Network"]),
        .library(name: "LocalStorage", targets: ["LocalStorage"]),
        .library(name: "Data", targets: ["Data"]),
    ],
    dependencies: [
        // DI コンテナ。各モジュールが自分の提供物を登録する（Factory 公式の流儀）。
        .package(url: "https://github.com/hmlongco/Factory.git", from: "3.3.2"),
    ],
    targets: [
        // 依存の向きは UI → Domain → Data → (Network / LocalStorage)。
        // Data が Domain を参照しないよう、モデルとリポジトリは Data に置く。

        // Network: リモートデータソース。プリミティブのみを扱い他層に依存しない。
        .target(name: "Network"),

        // LocalStorage: ローカルデータソース。DTO/プリミティブのみを扱い他層に依存しない。
        .target(name: "LocalStorage"),

        // Data: モデル・リポジトリ（protocol と実装）。データソースを束ねる。
        .target(
            name: "Data",
            dependencies: [
                "Network",
                "LocalStorage",
                .product(name: "FactoryKit", package: "Factory"),
            ]
        ),

        // Domain: UseCase（ビジネスロジック）。Data のリポジトリを利用する。
        .target(
            name: "Domain",
            dependencies: [
                "Data",
                .product(name: "FactoryKit", package: "Factory"),
            ]
        ),
    ]
)
