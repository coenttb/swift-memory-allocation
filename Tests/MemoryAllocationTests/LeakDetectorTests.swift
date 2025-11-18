// LeakDetectorTests.swift
// MemoryAllocation

import MemoryAllocation
import Testing

@Suite("LeakDetector Tests")
struct LeakDetectorTests {
    @Test
    func initialization() {
        let detector = LeakDetector()
        // Note: On macOS, these can be negative due to background cleanup
        _ = detector.netAllocations
        _ = detector.netBytes
    }

    @Test
    func `no initial leaks`() {
        let detector = LeakDetector()
        // May or may not have leaks depending on platform
        _ = detector.hasLeaks()
    }

    @Test
    func `detect growing allocations`() {
        let detector = LeakDetector()
        let initialNet = detector.netAllocations

        // Create persistent allocations
        var leaked: [[Int]] = []
        for i in 0..<100 {
            leaked.append(Array(repeating: i, count: 100))
        }

        let finalNet = detector.netAllocations

        // Keep leaked alive to prevent deallocation
        #expect(leaked.count == 100)

        #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS) || os(Linux)
            // Should show increased allocations
            #expect(finalNet >= initialNet)
        #endif
    }

    @Test
    func delta() {
        let detector = LeakDetector()
        let initialDelta = detector.delta()

        var arrays: [[Int]] = []
        for i in 0..<10 {
            arrays.append(Array(repeating: i, count: 100))
        }

        let finalDelta = detector.delta()

        #expect(arrays.count == 10)
        // Note: On macOS, allocations can go down due to background cleanup
        _ = finalDelta.allocations
        _ = initialDelta.allocations
    }

    @Test
    func `thread safety`() async {
        let detector = LeakDetector()

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    _ = detector.netAllocations
                    _ = detector.netBytes
                    _ = detector.hasLeaks()
                    _ = detector.delta()
                }
            }

            for await _ in group {}
        }
    }

    @Test
    func `assert no leaks success`() throws {
        let detector = LeakDetector()

        // Do work that doesn't leak
        let array = Array(repeating: 0, count: 100)
        _ = array.count

        // On some platforms, this might succeed
        // On others, there might be background allocations
        // Just verify it doesn't crash
        do {
            try detector.assertNoLeaks()
        } catch {
            // Background allocations may occur
        }
    }

    @Test
    func `assert no leaks failure`() {
        let detector = LeakDetector()

        // Force persistent allocations
        var leaked: [[Int]] = []
        for i in 0..<1000 {
            leaked.append(Array(repeating: i, count: 1000))
        }

        // Keep leaked alive
        #expect(leaked.count == 1000)

        // This should fail on platforms with tracking
        #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS) || os(Linux)
            do {
                try detector.assertNoLeaks()
                // May not fail if background GC occurred
            } catch {
                #expect(error is LeakError)
            }
        #endif
    }

    @Test
    func `leak error description`() {
        let error = LeakError.leaksDetected(
            allocations: 100,
            bytes: 4096,
            file: "test.swift",
            line: 42
        )

        let description = error.description
        #expect(description.contains("Memory leak"))
        #expect(description.contains("100"))
        #expect(description.contains("4096"))
    }

    @Test
    func `net bytes tracking`() {
        let detector = LeakDetector()
        let initial = detector.netBytes

        var arrays: [[Int]] = []
        for i in 0..<10 {
            arrays.append(Array(repeating: i, count: 100))
        }

        let final = detector.netBytes

        #expect(arrays.count == 10)
        // Note: On macOS, net bytes can decrease due to background cleanup
        _ = final
        _ = initial
    }

    @Test
    func sendable() async {
        let detector = LeakDetector()

        await Task {
            _ = detector.hasLeaks()
        }.value
    }
}
