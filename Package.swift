// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TorusSwiftDirectSDK",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "TorusSwiftDirectSDK",
            targets: ["TorusSwiftDirectSDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name:"BestLogger", url: "https://github.com/rathishubham7/swift-logger", from: "0.0.1"),
        .package(name:"TorusUtils", url: "https://github.com/torusresearch/torus-utils-swift", from: "0.0.1")
//        .package(name: "TorusUtils", path: "../torus-utils-swift")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "TorusSwiftDirectSDK",
            dependencies: ["TorusUtils", "BestLogger"],
            path: "Sources/TorusSwiftDirectSDK"),
        .testTarget(
            name: "TorusSwiftDirectSDKTests",
            dependencies: ["TorusSwiftDirectSDK"]),
    ]
)
