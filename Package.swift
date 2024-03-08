// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CustomAuth",
    platforms: [
        .iOS(.v13), .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "CustomAuth",
            targets: ["CustomAuth"])
    ],
    dependencies: [
        .package(name: "TorusUtils", url: "https://github.com/torusresearch/torus-utils-swift.git", from: "7.0.1"),
        .package(name: "jwt-kit", url: "https://github.com/vapor/jwt-kit.git", from: "4.13.0"),
        .package(name: "JWTDecode", url: "https://github.com/auth0/JWTDecode.swift.git", from: "3.1.0")
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
