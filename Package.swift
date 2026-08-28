// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-memory-allocation",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Memory Allocator",
            targets: ["Memory Allocator"]
        ),
        .library(
            name: "Memory Allocator Protocol",
            targets: ["Memory Allocator Protocol"]
        ),
        .library(
            name: "Memory Allocation",
            targets: ["Memory Allocation"]
        ),
        .library(
            name: "Memory Pool",
            targets: ["Memory Pool"]
        ),
        .library(
            name: "Memory Pool Test Support",
            targets: ["Memory Pool Test Support"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-memory.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-tagged.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-index.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Memory Allocator",
            dependencies: [
                .product(name: "Memory", package: "swift-memory"),
            ]
        ),
        .target(
            name: "Memory Allocator Protocol",
            dependencies: [
                .target(name: "Memory Allocator"),
                .product(name: "Memory", package: "swift-memory"),
            ]
        ),
        .target(
            name: "Memory Allocation",
            dependencies: [
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),
        .target(
            name: "Memory Pool",
            dependencies: [
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Index", package: "swift-index"),
            ]
        ),
        .target(
            name: "Memory Pool Test Support",
            dependencies: [
                .target(name: "Memory Pool"),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Index", package: "swift-index"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Memory Allocation Tests",
            dependencies: [
                .target(name: "Memory Allocator"),
                .target(name: "Memory Allocator Protocol"),
                .product(name: "Memory", package: "swift-memory"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
