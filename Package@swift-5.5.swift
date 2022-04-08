// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "pecker",
    products: [
        .executable(name: "pecker", targets: ["Pecker"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", .exact("0.50500.0")),
        .package(url: "https://github.com/apple/indexstore-db.git", .branch("release/5.5")),
        .package(url: "https://github.com/apple/swift-tools-support-core.git", .branch("main")),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .exact("0.3.2")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .executableTarget(
            name: "Pecker",
            dependencies: [
                "PeckerKit",
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")]
        ),
        .target(
            name: "PeckerKit",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "IndexStoreDB", package: "indexstore-db"),
                .product(name: "SwiftToolsSupport-auto", package: "swift-tools-support-core"),
                .product(name: "Yams", package: "Yams")
            ]
        ),
        .testTarget(
            name: "PeckerTests",
            dependencies: ["Pecker"]),
    ]
)
