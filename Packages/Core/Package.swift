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
        .library(name: "Model", targets: ["Model"]),
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "Network", targets: ["Network"]),
        .library(name: "Database", targets: ["Database"]),
        .library(name: "Datastore", targets: ["Datastore"]),
        .library(name: "Data", targets: ["Data"]),
    ],
    dependencies: [
        // DI コンテナ。各モジュールが自分の提供物を登録する（Factory 公式の流儀）。
        .package(url: "https://github.com/hmlongco/Factory.git", from: "3.3.2"),
    ],
    targets: [
        // 依存の向きは UI → Domain → Data → (Network / LocalStorage)。
        // モデルは依存を持たない葉（Model）として独立させ、各層から参照する（NiA の core:model 相当）。

        // Model: アプリ全体で使うドメインモデル。他層に依存しない葉。
        .target(name: "Model"),

        // Network: リモートデータソース。プリミティブ/DTO のみを扱い他層に依存しない。
        .target(name: "Network"),

        // Database: 構造化データのローカル保存（NiA の core:database 相当。Entity を持つ）。
        .target(name: "Database"),

        // Datastore: 設定値・秘匿情報の保存（NiA の core:datastore 相当。UserDefaults/Keychain）。
        .target(name: "Datastore"),

        // Data: リポジトリ（protocol と実装）。データソースを束ね、モデルへ変換する。
        .target(
            name: "Data",
            dependencies: [
                "Model",
                "Network",
                "Database",
                "Datastore",
                .product(name: "FactoryKit", package: "Factory"),
            ]
        ),

        // Domain: UseCase（ビジネスロジック）。モデルを扱い、Data のリポジトリを利用する。
        .target(
            name: "Domain",
            dependencies: [
                "Model",
                "Data",
                .product(name: "FactoryKit", package: "Factory"),
            ]
        ),
    ]
)
