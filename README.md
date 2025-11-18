# swift-memory-allocation

[![CI](https://github.com/coenttb/swift-memory-allocation/workflows/CI/badge.svg)](https://github.com/coenttb/swift-memory-allocation/actions/workflows/ci.yml)
![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

**Cross-platform memory allocation observability for Swift**

A focused library providing memory allocation tracking, leak detection, peak memory profiling, and allocation histograms across macOS and Linux.

## Features

- **Allocation Tracking** - Measure memory allocations in code blocks
- **Leak Detection** - Detect memory leaks by tracking net allocations
- **Peak Memory Tracking** - Monitor peak memory usage over time
- **Allocation Profiling** - Profile allocations with statistics and histograms
- **Cross-Platform** - Works on macOS and Linux with platform-optimized implementations
- **Thread-Safe** - All trackers are Sendable and safe for concurrent use
- **Zero Dependencies** - Pure Swift using only Darwin/Glibc platform primitives (no Foundation)

## Installation

Add `swift-memory-allocation` to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/coenttb/swift-memory-allocation", from: "0.1.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "MemoryAllocation", package: "swift-memory-allocation")
    ]
)
```

## Quick Start

### Basic Allocation Tracking

```swift
import MemoryAllocation

// Measure allocations in a code block
let (result, stats) = AllocationTracker.measure {
    let array = Array(repeating: 0, count: 1000)
    return array.count
}

print("Allocated \(stats.bytesAllocated) bytes")
print("Allocations: \(stats.allocations)")
print("Deallocations: \(stats.deallocations)")
```

### Leak Detection

```swift
let detector = LeakDetector()

// Your code here
var leaked: [[Int]] = []
for i in 0..<100 {
    leaked.append(Array(repeating: i, count: 100))
}

if detector.hasLeaks() {
    print("Warning: \(detector.netAllocations) leaked allocations")
    print("Net bytes: \(detector.netBytes)")
}

// Or assert no leaks
try detector.assertNoLeaks()  // Throws if leaks detected
```

### Peak Memory Tracking

```swift
let tracker = PeakMemoryTracker()

for i in 0..<100 {
    let array = Array(repeating: 0, count: i * 100)
    tracker.sample()  // Record current memory
}

print("Peak memory: \(tracker.peakBytes) bytes")
print("Peak allocations: \(tracker.peakAllocations)")
```

### Allocation Profiling

```swift
let profiler = AllocationProfiler()

// Profile multiple runs
for _ in 0..<100 {
    profiler.profile {
        let array = Array(repeating: 0, count: 1000)
        _ = array.reduce(0, +)
    }
}

// Analyze results
print("Mean: \(profiler.meanBytes) bytes")
print("Median: \(profiler.medianBytes) bytes")
print("P95: \(profiler.percentileBytes(95)) bytes")
print("P99: \(profiler.percentileBytes(99)) bytes")

// Generate histogram
let histogram = profiler.histogram(buckets: 10)
for bucket in histogram.buckets {
    print("\(bucket.lowerBound)-\(bucket.upperBound): \(bucket.count) (\(bucket.frequency)%)")
}
```

## Platform Differences

### macOS/iOS/watchOS/tvOS

Uses `malloc_zone_statistics` which provides:
- Current memory snapshot
- Blocks in use
- Total bytes in use

**Note**: On Darwin platforms, allocation deltas represent snapshots and can be negative due to background cleanup. This is expected behavior.

### Linux

Uses LD_PRELOAD malloc/free hooks which provide:
- Accurate allocation counting
- Deallocation tracking
- Per-thread statistics

**Note**: On Linux, you need to start tracking explicitly:

```swift
#if os(Linux)
AllocationStats.startTracking()
#endif
```

## API Overview

### `AllocationStats`

Core type representing allocation statistics.

```swift
public struct AllocationStats: Sendable, Equatable {
    public let allocations: Int
    public let deallocations: Int
    public let bytesAllocated: Int

    public var netAllocations: Int { allocations - deallocations }

    public static func capture() -> AllocationStats
    public static func delta(from start: AllocationStats, to end: AllocationStats) -> AllocationStats
}
```

### `AllocationTracker`

Measure allocations in code blocks.

```swift
public enum AllocationTracker {
    public static func measure<T>(_ operation: () throws -> T) rethrows -> (result: T, stats: AllocationStats)
    public static func measure<T>(_ operation: () async throws -> T) async rethrows -> (result: T, stats: AllocationStats)
    public static func measure(_ operation: () throws -> Void) rethrows -> AllocationStats
    public static func measure(_ operation: () async throws -> Void) async rethrows -> AllocationStats
}
```

### `LeakDetector`

Detect memory leaks by tracking net allocations.

```swift
public final class LeakDetector: Sendable {
    public init()

    public func hasLeaks() -> Bool
    public var netAllocations: Int { get }
    public var netBytes: Int { get }
    public func delta() -> AllocationStats
    public func assertNoLeaks(file: StaticString = #file, line: UInt = #line) throws
}
```

### `PeakMemoryTracker`

Track peak memory usage.

```swift
public final class PeakMemoryTracker: Sendable {
    public init()

    public func sample()
    public var peakBytes: Int { get }
    public var peakAllocations: Int { get }
    public var samples: [AllocationStats] { get }
    public var current: AllocationStats { get }
    public func reset()

    public static func track<T>(_ operation: (PeakMemoryTracker) throws -> T) rethrows -> (result: T, peak: AllocationStats)
    public static func track<T>(_ operation: (PeakMemoryTracker) async throws -> T) async rethrows -> (result: T, peak: AllocationStats)
}
```

### `AllocationProfiler`

Profile allocations with statistics and histograms.

```swift
public final class AllocationProfiler: Sendable {
    public init()

    public func profile<T>(_ operation: () throws -> T) rethrows -> T
    public func profile<T>(_ operation: () async throws -> T) async rethrows -> T

    public var count: Int { get }
    public var allMeasurements: [AllocationStats] { get }

    public var meanBytes: Double { get }
    public var medianBytes: Int { get }
    public func percentileBytes(_ percentile: Int) -> Int

    public var meanAllocations: Double { get }
    public var medianAllocations: Int { get }
    public func percentileAllocations(_ percentile: Int) -> Int

    public func histogram(buckets: Int = 10) -> AllocationHistogram
    public func reset()
}
```

## Use Cases

### 1. Performance Testing

Track memory allocations in your test suite:

```swift
func testMemoryEfficiency() throws {
    let stats = AllocationTracker.measure {
        myExpensiveOperation()
    }

    // Assert maximum allocation budget
    #expect(stats.bytesAllocated <= 1024 * 1024)  // Max 1MB
}
```

### 2. CI/CD Regression Detection

Profile allocations across builds:

```swift
let profiler = AllocationProfiler()

for _ in 0..<1000 {
    profiler.profile {
        criticalPath()
    }
}

// Compare with baseline
let p95 = profiler.percentileBytes(95)
#expect(p95 <= baselineP95)
```

### 3. Production Monitoring

Detect leaks in long-running services:

```swift
let detector = LeakDetector()

while running {
    handleRequest()

    if detector.netAllocations > threshold {
        logger.warning("Potential leak: \(detector.netBytes) bytes")
    }
}
```

### 4. Memory Profiling

Understand allocation patterns:

```swift
let tracker = PeakMemoryTracker()

for batch in batches {
    processBatch(batch)
    tracker.sample()
}

print("Peak during processing: \(tracker.peakBytes) bytes")
```

## Requirements

- Swift 6.2+
- macOS 13+, iOS 16+, watchOS 9+, tvOS 16+, or Linux

## License

This library is released under the Apache License 2.0. See [LICENSE](LICENSE) for details.

## Related Projects

- [swift-testing-performance](https://github.com/coenttb/swift-testing-performance) - Performance measurement traits for Swift Testing
