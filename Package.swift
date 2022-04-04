// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "pecker",
    products: [
        .executable(name: "pecker", targets: ["Pecker"]),
        .library(name: "PeckerKit", targets: ["PeckerKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", exact: "0.50600.1"),
        .package(url: "https://github.com/apple/indexstore-db.git", branch: "swift-5.6-RELEASE"),
        .package(url: "https://github.com/apple/swift-tools-support-core.git", from: "0.2.5"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.1.1"),
    ],
    targets: [
        .executableTarget(
            name: "Pecker",
            dependencies: [
                .byName(name: "PeckerKit"),
                .product(name: "SwiftToolsSupport", package: "swift-tools-support-core"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")]
        ),
        .target(
            name: "PeckerKit",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxParser", package: "swift-syntax"),
                .product(name: "IndexStoreDB", package: "indexstore-db"),
                .product(name: "SwiftToolsSupport", package: "swift-tools-support-core"),
                .product(name: "Yams", package: "Yams")
            ]
        ),
        .testTarget(
            name: "PeckerTests",
            dependencies: [.byName(name: "Pecker")]),
    ]
)
