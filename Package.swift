// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CustomAuth",
    platforms: [
        .iOS(.v13), // .macOS(.v11) // Needs some modification to work since UIKIT is for iOS
    ],
    products: [
        .library(
            name: "CustomAuth",
            targets: ["CustomAuth"])
    ],
    dependencies: [
        .package(name: "TorusUtils", url: "https://github.com/torusresearch/torus-utils-swift.git", from: "6.1.0"),
        .package(name: "jwt-kit", url: "https://github.com/vapor/jwt-kit.git", from: "4.0.0"),
        .package(name: "JWTDecode", url: "https://github.com/auth0/JWTDecode.swift.git", from: "3.1.0"),
        .package(name: "secp256k1", url: "https://github.com/GigaBitcoin/secp256k1.swift.git", .exact("0.12.2")),
    ],
    targets: [
        .target(
            name: "CustomAuth",
            dependencies: ["TorusUtils", "JWTDecode"]),
        .testTarget(
            name: "CustomAuthTests",
            dependencies: ["CustomAuth", "secp256k1", .product(name: "JWTKit", package: "jwt-kit")])
    ],        swiftLanguageVersions: [.v5]
)
