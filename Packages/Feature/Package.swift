// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Feature",
    defaultLocalization: "ja",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "Feature", targets: ["Feature"])
    ],
    dependencies: [
        .package(path: "../Core"),
        // DI コンテナ。Core は非依存のままにし、コンポジションルートである Feature でのみ使う。
        .package(url: "https://github.com/hmlongco/Factory.git", from: "3.3.2"),
    ],
    targets: [
        .target(
            name: "Feature",
            dependencies: [
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
        )
    ]
)
