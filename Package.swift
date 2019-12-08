// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "pecker",
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", .exact("0.50100.0")),
        .package(url: "https://github.com/apple/indexstore-db.git", .branch("swift-5.1-branch")),
        .package(url: "https://github.com/apple/swift-package-manager.git", .branch("master")),
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "pecker",
            dependencies: [
                "PeckerKit",
                "TSCUtility"]
        ),
        .target(
            name: "PeckerKit",
            dependencies: [
                "SwiftSyntax",
                "IndexStoreDB",
                "TSCUtility",
                "Yams"
            ]
        ),
        .testTarget(
            name: "PeckerTests",
            dependencies: ["pecker"]),
    ]
)
