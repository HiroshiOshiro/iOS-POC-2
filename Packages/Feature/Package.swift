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
        .package(path: "../Core")
    ],
    targets: [
        .target(
            name: "Feature",
            dependencies: [
                .product(name: "Domain", package: "Core"),
                .product(name: "Data", package: "Core"),
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
