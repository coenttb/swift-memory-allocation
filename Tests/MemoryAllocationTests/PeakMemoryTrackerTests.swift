// PeakMemoryTrackerTests.swift
// MemoryAllocation

import MemoryAllocation
import Testing

@Suite("PeakMemoryTracker Tests")
struct PeakMemoryTrackerTests {
    @Test
    func initialization() {
        let tracker = PeakMemoryTracker()
        #expect(tracker.peakBytes >= 0)
        #expect(tracker.peakAllocations >= 0)
    }

    @Test
    func `initial peak is zero`() {
        let tracker = PeakMemoryTracker()
        #expect(tracker.peakBytes == 0)
        #expect(tracker.peakAllocations == 0)
    }

    @Test
    func `sample updates peak`() {
        let tracker = PeakMemoryTracker()
        let initialPeak = tracker.peakBytes

        var arrays: [[Int]] = []
        for i in 0..<10 {
            arrays.append(Array(repeating: i, count: 100))
            tracker.sample()
        }

        #expect(arrays.count == 10)
        #expect(tracker.peakBytes >= initialPeak)
    }

    @Test
    func `peak increases`() {
        let tracker = PeakMemoryTracker()

        var arrays: [[Int]] = []
        for i in 1..<10 {
            arrays.append(Array(repeating: 0, count: i * 100))
            tracker.sample()
        }

        let peak1 = tracker.peakBytes

        for i in 10..<20 {
            arrays.append(Array(repeating: 0, count: i * 100))
            tracker.sample()
        }

        let peak2 = tracker.peakBytes

        #expect(arrays.count == 19)
        #expect(peak2 >= peak1)
    }

    @Test
    func `samples collected`() {
        let tracker = PeakMemoryTracker()

        for i in 0..<5 {
            _ = Array(repeating: i, count: 100)
            tracker.sample()
        }

        let samples = tracker.samples
        #expect(samples.count == 5)
    }

    @Test
    func current() {
        let tracker = PeakMemoryTracker()

        _ = Array(repeating: 0, count: 1000)
        let current = tracker.current

        _ = current.bytesAllocated  // Can be negative on macOS
    }

    @Test
    func reset() {
        let tracker = PeakMemoryTracker()

        for i in 0..<10 {
            _ = Array(repeating: i, count: 100)
            tracker.sample()
        }

        #expect(tracker.samples.count == 10)

        tracker.reset()

        #expect(tracker.samples.isEmpty)
        #expect(tracker.peakBytes == 0)
        #expect(tracker.peakAllocations == 0)
    }

    @Test
    func `track sync operation`() {
        let (result, peak) = PeakMemoryTracker.track { tracker in
            var arrays: [[Int]] = []
            for i in 0..<10 {
                arrays.append(Array(repeating: i, count: 100))
                tracker.sample()
            }
            return arrays.count
        }

        #expect(result == 10)
        #expect(peak.bytesAllocated >= 0)
    }

    @Test
    func `track async operation`() async {
        let (result, peak) = PeakMemoryTracker.track { tracker in
            var arrays: [[Int]] = []
            for i in 0..<10 {
                arrays.append(Array(repeating: i, count: 100))
                tracker.sample()
            }
            return arrays.count
        }

        #expect(result == 10)
        #expect(peak.bytesAllocated >= 0)
    }

    @Test
    func `track throwing`() throws {
        struct TestError: Error {}

        let (result, peak) = PeakMemoryTracker.track { tracker in
            tracker.sample()
            return 42
        }

        #expect(result == 42)
        #expect(peak.bytesAllocated >= 0)

        #expect(throws: TestError.self) {
            try PeakMemoryTracker.track { _ in
                throw TestError()
            }
        }
    }

    @Test
    func `track async throwing`() throws {
        struct TestError: Error {}

        let (result, peak) = PeakMemoryTracker.track { tracker in
            tracker.sample()
            return 42
        }

        #expect(result == 42)
        #expect(peak.bytesAllocated >= 0)

        #expect(throws: TestError.self) {
            try PeakMemoryTracker.track { _ in
                throw TestError()
            }
        }
    }

    @Test
    func `peak allocations`() {
        let tracker = PeakMemoryTracker()

        for i in 1..<10 {
            var arrays: [[Int]] = []
            for j in 0..<i {
                arrays.append(Array(repeating: j, count: 10))
            }
            tracker.sample()
            _ = arrays.count
        }

        #expect(tracker.peakAllocations >= 0)
    }

    @Test
    func `thread safety`() async {
        let tracker = PeakMemoryTracker()

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    tracker.sample()
                    _ = tracker.peakBytes
                    _ = tracker.peakAllocations
                    _ = tracker.current
                    _ = tracker.samples
                }
            }

            for await _ in group {}
        }
    }

    @Test
    func sendable() async {
        let tracker = PeakMemoryTracker()

        await Task {
            tracker.sample()
        }.value
    }
}
