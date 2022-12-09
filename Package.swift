// swift-tools-version:5.2
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
        .package(name: "TorusUtils", url: "https://github.com/torusresearch/torus-utils-swift.git", from: "4.0.0"),
        .package(name: "jwt-kit", url: "https://github.com/vapor/jwt-kit.git", from: "4.0.0"),
        .package(name: "JWTDecode", url: "https://github.com/auth0/JWTDecode.swift.git", from: "2.6.3")
    ],
    targets: [
        .target(
            name: "CustomAuth",
            dependencies: ["TorusUtils", "JWTDecode"]),
        .testTarget(
            name: "CustomAuthTests",
            dependencies: ["CustomAuth", .product(name: "JWTKit", package: "jwt-kit")])
    ],        swiftLanguageVersions: [.v5]
)
