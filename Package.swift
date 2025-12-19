// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-memory-allocation",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "MemoryAllocation",
            targets: ["MemoryAllocation"]
        )
    ],
    targets: [
        .target(
            name: "MemoryAllocation",
            dependencies: [
                .target(name: "CAllocationTracking", condition: .when(platforms: [.linux]))
            ]
        ),
        .target(
            name: "CAllocationTracking",
            linkerSettings: [
                .linkedLibrary("dl", .when(platforms: [.linux]))
            ]
        ),
        .testTarget(
            name: "MemoryAllocation Tests",
            dependencies: ["MemoryAllocation"]
        )
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let existing = target.swiftSettings ?? []
    target.swiftSettings = existing + [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility")
    ]
}
