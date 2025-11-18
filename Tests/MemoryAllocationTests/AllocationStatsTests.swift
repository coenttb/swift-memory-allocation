// AllocationStatsTests.swift
// MemoryAllocation

import MemoryAllocation
import Testing

@Suite("AllocationStats Tests")
struct AllocationStatsTests {
    @Test
    func `default initialization`() {
        let stats = AllocationStats()

        #expect(stats.allocations == 0)
        #expect(stats.deallocations == 0)
        #expect(stats.bytesAllocated == 0)
        #expect(stats.netAllocations == 0)
    }

    @Test
    func `custom initialization`() {
        let stats = AllocationStats(
            allocations: 10,
            deallocations: 5,
            bytesAllocated: 1024
        )

        #expect(stats.allocations == 10)
        #expect(stats.deallocations == 5)
        #expect(stats.bytesAllocated == 1024)
        #expect(stats.netAllocations == 5)
    }

    @Test
    func `net allocations`() {
        let stats = AllocationStats(
            allocations: 100,
            deallocations: 70,
            bytesAllocated: 2048
        )

        #expect(stats.netAllocations == 30)
    }

    @Test
    func delta() {
        let start = AllocationStats(
            allocations: 10,
            deallocations: 5,
            bytesAllocated: 1024
        )

        let end = AllocationStats(
            allocations: 20,
            deallocations: 12,
            bytesAllocated: 2048
        )

        let delta = AllocationStats.delta(from: start, to: end)

        #expect(delta.allocations == 10)
        #expect(delta.deallocations == 7)
        #expect(delta.bytesAllocated == 1024)
    }

    @Test
    func `delta with no change`() {
        let stats = AllocationStats(
            allocations: 10,
            deallocations: 5,
            bytesAllocated: 1024
        )

        let delta = AllocationStats.delta(from: stats, to: stats)

        #expect(delta.allocations == 0)
        #expect(delta.deallocations == 0)
        #expect(delta.bytesAllocated == 0)
    }

    @Test
    func capture() {
        let stats = AllocationStats.capture()

        // Should return some stats (or zero on unsupported platforms)
        #expect(stats.allocations >= 0)
        #expect(stats.deallocations >= 0)
        _ = stats.bytesAllocated  // Can be negative on macOS
    }

    @Test
    func `multiple captures`() {
        let first = AllocationStats.capture()
        _ = Array(repeating: 0, count: 1000)
        let second = AllocationStats.capture()

        // On supported platforms, second should show more usage
        // On unsupported platforms, both will be zero
        let delta = AllocationStats.delta(from: first, to: second)

        // On Darwin platforms, deltas can be negative due to background cleanup
        // On Linux with tracking enabled, deltas should be positive
        // On unsupported platforms, deltas will be zero
        #if os(Linux)
            #expect(delta.bytesAllocated >= 0)
        #else
            // On macOS, just verify we got a value (can be negative, zero, or positive)
            _ = delta.bytesAllocated
        #endif
    }

    @Test
    func equality() {
        let stats1 = AllocationStats(
            allocations: 10,
            deallocations: 5,
            bytesAllocated: 1024
        )

        let stats2 = AllocationStats(
            allocations: 10,
            deallocations: 5,
            bytesAllocated: 1024
        )

        let stats3 = AllocationStats(
            allocations: 11,
            deallocations: 5,
            bytesAllocated: 1024
        )

        #expect(stats1 == stats2)
        #expect(stats1 != stats3)
    }

    @Test
    func sendable() async {
        let stats = AllocationStats(
            allocations: 10,
            deallocations: 5,
            bytesAllocated: 1024
        )

        // Should compile - AllocationStats is Sendable
        await Task {
            #expect(stats.allocations == 10)
        }.value
    }

    #if os(Linux)
        @Test
        func `linux tracking`() {
            AllocationStats.startTracking()
            _ = Array(repeating: 0, count: 1000)
            let stats = AllocationStats.stopTracking()

            #expect(stats.allocations > 0)
            #expect(stats.bytesAllocated > 0)
        }

        @Test
        func `linux tracking reset`() {
            AllocationStats.startTracking()
            _ = Array(repeating: 0, count: 1000)
            AllocationStats.resetTracking()

            let stats = AllocationStats.capture()
            #expect(stats.allocations == 0)
            #expect(stats.bytesAllocated == 0)
        }
    #endif
}
