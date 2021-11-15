// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TorusSwiftDirectSDK",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "TorusSwiftDirectSDK",
            targets: ["TorusSwiftDirectSDK"]),
    ],
    dependencies: [
        .package(name:"TorusUtils", url: "https://github.com/torusresearch/torus-utils-swift", from: "1.2.0"),
        .package(name:"FetchNodeDetails", url: "https://github.com/torusresearch/fetch-node-details-swift", from: "1.2.0"),
        .package(name:"jwt-kit", url: "https://github.com/vapor/jwt-kit.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "TorusSwiftDirectSDK",
            dependencies: ["TorusUtils"],
            path: "Sources/TorusSwiftDirectSDK"),
        .testTarget(
            name: "TorusSwiftDirectSDKTests",
            dependencies: ["TorusSwiftDirectSDK", .product(name: "JWTKit", package: "jwt-kit")]),
    ]
)
