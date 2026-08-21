// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-memory-allocation-primitives",
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
            name: "Memory Allocator Protocol Primitives",
            targets: ["Memory Allocator Protocol Primitives"]
        ),

        .library(
            name: "Memory Allocator Arena Primitives",
            targets: ["Memory Allocator Arena Primitives"]
        ),

        .library(
            name: "Memory Allocator Pool Primitives",
            targets: ["Memory Allocator Pool Primitives"]
        ),

        .library(
            name: "Memory Allocation Primitive",
            targets: ["Memory Allocation Primitive"]
        ),

        .library(
            name: "Memory Allocation Primitives",
            targets: ["Memory Allocation Primitives"]
        ),

        .library(
            name: "Memory Allocation Primitives Test Support",
            targets: ["Memory Allocation Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-primitives/swift-memory-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-tagged-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-index-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-bit-vector-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-affine-primitives.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Memory Allocator Primitive",
            dependencies: [
                .product(name: "Memory Primitive", package: "swift-memory-primitives"),
                .product(name: "Memory Region Primitives", package: "swift-memory-primitives"),
                .product(name: "Memory Address Primitives", package: "swift-memory-primitives"),
                .product(name: "Memory Alignment Primitives", package: "swift-memory-primitives"),
            ]
        ),

        .target(
            name: "Memory Allocator Protocol Primitives",
            dependencies: [
                "Memory Allocator Primitive",
                .product(name: "Memory Primitive", package: "swift-memory-primitives"),
                .product(name: "Memory Region Primitives", package: "swift-memory-primitives"),
                .product(name: "Memory Address Primitives", package: "swift-memory-primitives"),
                .product(name: "Memory Alignment Primitives", package: "swift-memory-primitives"),
            ]
        ),

        .target(
            name: "Memory Allocation Primitive",
            dependencies: [
                "Memory Allocator Primitive",
                .product(name: "Memory Primitive", package: "swift-memory-primitives"),
                .product(name: "Memory Address Primitives", package: "swift-memory-primitives"),
                .product(name: "Memory Alignment Primitives", package: "swift-memory-primitives"),
                .product(name: "Tagged Primitives", package: "swift-tagged-primitives"),
            ]
        ),

        .target(
            name: "Memory Allocator Arena Primitives",
            dependencies: [
                "Memory Allocator Primitive",
                "Memory Allocator Protocol Primitives",
                "Memory Allocation Primitive",
                .product(name: "Memory Primitive", package: "swift-memory-primitives"),
                .product(name: "Memory Region Primitives", package: "swift-memory-primitives"),
                .product(name: "Memory Address Primitives", package: "swift-memory-primitives"),
                .product(name: "Memory Alignment Primitives", package: "swift-memory-primitives"),
                .product(
                    name: "Memory Primitives Standard Library Integration",
                    package: "swift-memory-primitives"
                ),
            ]
        ),

        .target(
            name: "Memory Allocator Pool Primitives",
            dependencies: [
                "Memory Allocator Primitive",
                "Memory Allocator Protocol Primitives",
                "Memory Allocation Primitive",
                .product(name: "Memory Primitive", package: "swift-memory-primitives"),
                .product(name: "Memory Region Primitives", package: "swift-memory-primitives"),
                .product(name: "Memory Address Primitives", package: "swift-memory-primitives"),
                .product(name: "Memory Alignment Primitives", package: "swift-memory-primitives"),
                .product(
                    name: "Memory Primitives Standard Library Integration",
                    package: "swift-memory-primitives"
                ),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Bit Vector Primitives", package: "swift-bit-vector-primitives"),
                .product(name: "Affine Discrete Primitives", package: "swift-affine-primitives"),
                .product(
                    name: "Affine Primitives Standard Library Integration",
                    package: "swift-affine-primitives"
                ),
            ]
        ),

        .target(
            name: "Memory Allocation Primitives",
            dependencies: [
                "Memory Allocator Primitive",
                "Memory Allocator Protocol Primitives",
                "Memory Allocation Primitive",
                "Memory Allocator Arena Primitives",
                "Memory Allocator Pool Primitives",
            ]
        ),

        .target(
            name: "Memory Allocation Primitives Test Support",
            dependencies: [
                "Memory Allocator Pool Primitives",
                .product(name: "Memory Primitive", package: "swift-memory-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
            ],
            path: "Tests/Support"
        ),

        .testTarget(
            name: "Memory Allocation Primitives Tests",
            dependencies: [
                "Memory Allocation Primitives",
                "Memory Allocation Primitives Test Support",
                .product(name: "Index Primitives", package: "swift-index-primitives"),
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
