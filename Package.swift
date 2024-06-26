// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CustomAuth",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "CustomAuth",
            targets: ["CustomAuth"])
    ],
    dependencies: [
        .package(url: "https://github.com/torusresearch/torus-utils-swift.git", from: "8.1.0"),
        .package(name: "jwt-kit", url: "https://github.com/vapor/jwt-kit.git", from: "4.13.0"),
        .package(name: "JWTDecode", url: "https://github.com/auth0/JWTDecode.swift.git", from: "3.1.0"),
        .package(url: "https://github.com/tkey/curvelib.swift", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "CustomAuth",
            dependencies: ["JWTDecode", .product(name: "curveSecp256k1", package: "curvelib.swift"), .product(name: "TorusUtils", package: "torus-utils-swift")]),
        .testTarget(
            name: "CustomAuthTests",
            dependencies: ["CustomAuth", .product(name: "JWTKit", package: "jwt-kit")])
    ],        swiftLanguageVersions: [.v5]
)
