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
            name: "Memory Allocator Primitive",
            targets: ["Memory Allocator Primitive"]
        ),

        .library(
            name: "Memory Allocator Protocol",
            targets: ["Memory Allocator Protocol"]
        ),

        .library(
            name: "Memory Allocator Arena",
            targets: ["Memory Allocator Arena"]
        ),

        .library(
            name: "Memory Allocator Pool",
            targets: ["Memory Allocator Pool"]
        ),

        .library(
            name: "Memory Allocation Primitive",
            targets: ["Memory Allocation Primitive"]
        ),

        .library(
            name: "Memory Allocation",
            targets: ["Memory Allocation"]
        ),

        .library(
            name: "Memory Allocation Test Support",
            targets: ["Memory Allocation Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-molecules/swift-memory.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-tagged.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-index.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-bit-vector.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-affine.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Memory Allocator Primitive",
            dependencies: [
                .product(name: "Memory Primitive", package: "swift-memory"),
                .product(name: "Memory Region", package: "swift-memory"),
                .product(name: "Memory Address", package: "swift-memory"),
                .product(name: "Memory Alignment", package: "swift-memory"),
            ]
        ),

        .target(
            name: "Memory Allocator Protocol",
            dependencies: [
                "Memory Allocator Primitive",
                .product(name: "Memory Primitive", package: "swift-memory"),
                .product(name: "Memory Region", package: "swift-memory"),
                .product(name: "Memory Address", package: "swift-memory"),
                .product(name: "Memory Alignment", package: "swift-memory"),
            ]
        ),

        .target(
            name: "Memory Allocation Primitive",
            dependencies: [
                "Memory Allocator Primitive",
                .product(name: "Memory Primitive", package: "swift-memory"),
                .product(name: "Memory Address", package: "swift-memory"),
                .product(name: "Memory Alignment", package: "swift-memory"),
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),

        .target(
            name: "Memory Allocator Arena",
            dependencies: [
                "Memory Allocator Primitive",
                "Memory Allocator Protocol",
                "Memory Allocation Primitive",
                .product(name: "Memory Primitive", package: "swift-memory"),
                .product(name: "Memory Region", package: "swift-memory"),
                .product(name: "Memory Address", package: "swift-memory"),
                .product(name: "Memory Alignment", package: "swift-memory"),
                .product(
                    name: "Memory Standard Library Integration",
                    package: "swift-memory"
                ),
            ]
        ),

        .target(
            name: "Memory Allocator Pool",
            dependencies: [
                "Memory Allocator Primitive",
                "Memory Allocator Protocol",
                "Memory Allocation Primitive",
                .product(name: "Memory Primitive", package: "swift-memory"),
                .product(name: "Memory Region", package: "swift-memory"),
                .product(name: "Memory Address", package: "swift-memory"),
                .product(name: "Memory Alignment", package: "swift-memory"),
                .product(
                    name: "Memory Standard Library Integration",
                    package: "swift-memory"
                ),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Bit Vector", package: "swift-bit-vector"),
                .product(name: "Affine Discrete", package: "swift-affine"),
                .product(
                    name: "Affine Standard Library Integration",
                    package: "swift-affine"
                ),
            ]
        ),

        .target(
            name: "Memory Allocation",
            dependencies: [
                "Memory Allocator Primitive",
                "Memory Allocator Protocol",
                "Memory Allocation Primitive",
                "Memory Allocator Arena",
                "Memory Allocator Pool",
            ]
        ),

        .target(
            name: "Memory Allocation Test Support",
            dependencies: [
                "Memory Allocator Pool",
                .product(name: "Memory Primitive", package: "swift-memory"),
                .product(name: "Index", package: "swift-index"),
            ],
            path: "Tests/Support"
        ),

        .testTarget(
            name: "Memory Allocation Tests",
            dependencies: [
                "Memory Allocation",
                "Memory Allocation Test Support",
                .product(name: "Index", package: "swift-index"),
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
