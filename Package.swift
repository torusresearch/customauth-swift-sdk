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
        .package(name:"TorusUtils", url: "https://github.com/torusresearch/torus-utils-swift", from: "1.0.0"),
//        .package(name:"TorusUtils", path: "../torus-utils-swift"),
    ],
    targets: [
        .target(
            name: "TorusSwiftDirectSDK",
            dependencies: ["TorusUtils", "BestLogger"],
            path: "Sources/TorusSwiftDirectSDK"),
        .testTarget(
            name: "TorusSwiftDirectSDKTests",
            dependencies: ["TorusSwiftDirectSDK"]),
    ]
)
