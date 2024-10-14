// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CustomAuth",
    platforms: [
        .iOS(.v14), .macOS(.v11)
    ],
    products: [
        .library(
            name: "CustomAuth",
            targets: ["CustomAuth"])
    ],
    dependencies: [
        .package(url: "https://github.com/torusresearch/torus-utils-swift.git", branch: "remove_celeste_support"),
        .package(url: "https://github.com/auth0/JWTDecode.swift.git", from: "3.1.0"),
        // NB: jwt-kit may only be a test dependency or it will break cocoapods support
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "4.13.0"),
    ],
    targets: [
        .target(
            name: "CustomAuth",
            dependencies: [.product(name: "JWTDecode", package: "JWTDecode.swift"), .product(name: "TorusUtils", package: "torus-utils-swift")]),
        .testTarget(
            name: "CustomAuthTests",
            dependencies: ["CustomAuth", .product(name: "JWTKit", package: "jwt-kit")])
    ],        swiftLanguageVersions: [.v5]
)
