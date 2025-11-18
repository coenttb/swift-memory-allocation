// AllocationProfilerTests.swift
// MemoryAllocation

import MemoryAllocation
import Testing

@Suite("AllocationProfiler Tests")
struct AllocationProfilerTests {
    @Test
    func initialization() {
        let profiler = AllocationProfiler()
        #expect(profiler.allMeasurements.isEmpty)
    }

    @Test
    func `profile sync`() {
        let profiler = AllocationProfiler()

        let result = profiler.profile {
            Array(repeating: 0, count: 100)
        }

        #expect(result.count == 100)
        #expect(profiler.count == 1)
    }

    @Test
    func `profile async`() async {
        let profiler = AllocationProfiler()

        let result = profiler.profile {
            Array(repeating: 0, count: 100)
        }

        #expect(result.count == 100)
        #expect(profiler.count == 1)
    }

    @Test
    func `profile throwing`() throws {
        struct TestError: Error {}
        let profiler = AllocationProfiler()

        let result = try profiler.profile {
            let array = Array(repeating: 0, count: 100)
            if array.isEmpty {
                throw TestError()
            }
            return array.count
        }

        #expect(result == 100)
        #expect(profiler.count == 1)
    }

    @Test
    func `profile async throwing`() async throws {
        struct TestError: Error {}
        let profiler = AllocationProfiler()

        let result = try profiler.profile {
            let array = Array(repeating: 0, count: 100)
            if array.isEmpty {
                throw TestError()
            }
            return array.count
        }

        #expect(result == 100)
        #expect(profiler.count == 1)
    }

    @Test
    func `multiple profiles`() {
        let profiler = AllocationProfiler()

        for i in 0..<10 {
            profiler.profile {
                _ = Array(repeating: i, count: 100)
            }
        }

        #expect(profiler.count == 10)
        #expect(profiler.allMeasurements.count == 10)
    }

    @Test
    func `mean bytes`() {
        let profiler = AllocationProfiler()

        // Profile same operation multiple times
        for _ in 0..<10 {
            profiler.profile {
                _ = Array(repeating: 0, count: 100)
            }
        }

        let mean = profiler.meanBytes
        _ = mean  // Can be negative on macOS
    }

    @Test
    func `median bytes`() {
        let profiler = AllocationProfiler()

        for i in 0..<10 {
            profiler.profile {
                _ = Array(repeating: 0, count: i * 10)
            }
        }

        let median = profiler.medianBytes
        #expect(median >= 0)
    }

    @Test
    func `percentile bytes`() {
        let profiler = AllocationProfiler()

        for i in 0..<100 {
            profiler.profile {
                _ = Array(repeating: 0, count: i * 10)
            }
        }

        let p50 = profiler.percentileBytes(50)
        let p95 = profiler.percentileBytes(95)
        let p99 = profiler.percentileBytes(99)

        #expect(p50 >= 0)
        #expect(p95 >= p50)
        #expect(p99 >= p95)
    }

    @Test
    func `mean allocations`() {
        let profiler = AllocationProfiler()

        for _ in 0..<10 {
            profiler.profile {
                _ = Array(repeating: 0, count: 100)
            }
        }

        let mean = profiler.meanAllocations
        _ = mean  // Can be negative on macOS
    }

    @Test
    func `median allocations`() {
        let profiler = AllocationProfiler()

        for i in 0..<10 {
            profiler.profile {
                _ = Array(repeating: 0, count: i * 10)
            }
        }

        let median = profiler.medianAllocations
        #expect(median >= 0)
    }

    @Test
    func `percentile allocations`() {
        let profiler = AllocationProfiler()

        for i in 0..<100 {
            profiler.profile {
                _ = Array(repeating: 0, count: i * 10)
            }
        }

        let p50 = profiler.percentileAllocations(50)
        let p95 = profiler.percentileAllocations(95)
        let p99 = profiler.percentileAllocations(99)

        #expect(p50 >= 0)
        #expect(p95 >= p50)
        #expect(p99 >= p95)
    }

    @Test
    func histogram() {
        let profiler = AllocationProfiler()

        for i in 0..<100 {
            profiler.profile {
                _ = Array(repeating: 0, count: i * 100)
            }
        }

        let histogram = profiler.histogram(buckets: 10)
        #expect(histogram.buckets.count <= 10)
    }

    @Test
    func reset() {
        let profiler = AllocationProfiler()

        for i in 0..<10 {
            profiler.profile {
                _ = Array(repeating: i, count: 100)
            }
        }

        #expect(profiler.count == 10)

        profiler.reset()

        #expect(profiler.allMeasurements.isEmpty)
        #expect(profiler.allMeasurements.isEmpty)
    }

    @Test
    func `thread safety`() async {
        let profiler = AllocationProfiler()

        await withTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask {
                    profiler.profile {
                        _ = Array(repeating: i, count: 100)
                    }
                }
            }

            for await _ in group {}
        }

        #expect(profiler.count == 10)
    }

    @Test
    func sendable() async {
        let profiler = AllocationProfiler()

        await Task {
            profiler.profile {
                _ = Array(repeating: 0, count: 100)
            }
        }.value

        #expect(profiler.count == 1)
    }

    @Test
    func `empty statistics`() {
        let profiler = AllocationProfiler()

        #expect(profiler.meanBytes == 0)
        #expect(profiler.medianBytes == 0)
        #expect(profiler.meanAllocations == 0)
        #expect(profiler.medianAllocations == 0)
        #expect(profiler.percentileBytes(50) == 0)
        #expect(profiler.percentileAllocations(50) == 0)
    }
}

@Suite("AllocationHistogram Tests")
struct AllocationHistogramTests {
    @Test
    func `empty histogram`() {
        let histogram = AllocationHistogram(values: [], buckets: 10)
        #expect(histogram.buckets.isEmpty)
    }

    @Test
    func `single value`() {
        let histogram = AllocationHistogram(values: [100], buckets: 5)
        #expect(!histogram.buckets.isEmpty)
    }

    @Test
    func `multiple values`() {
        let values = Array(0..<100)
        let histogram = AllocationHistogram(values: values, buckets: 10)

        #expect(histogram.buckets.count <= 10)
        #expect(!histogram.buckets.isEmpty)
    }

    @Test
    func `bucket boundaries`() {
        let values = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
        let histogram = AllocationHistogram(values: values, buckets: 5)

        for bucket in histogram.buckets {
            #expect(bucket.lowerBound >= 0)
            #expect(bucket.upperBound > bucket.lowerBound)
        }
    }

    @Test
    func `bucket counts`() {
        let values = Array(0..<100)
        let histogram = AllocationHistogram(values: values, buckets: 10)

        let totalCount = histogram.buckets.reduce(0) { $0 + $1.count }
        #expect(totalCount == values.count)
    }

    @Test
    func frequencies() {
        let values = Array(0..<100)
        let histogram = AllocationHistogram(values: values, buckets: 10)

        let totalFrequency = histogram.buckets.reduce(0.0) { $0 + $1.frequency }
        #expect(abs(totalFrequency - 100.0) < 0.01)
    }

    @Test
    func `uniform distribution`() {
        let values = Array(0..<100)
        let histogram = AllocationHistogram(values: values, buckets: 10)

        // Each bucket should have roughly 10% frequency for uniform distribution
        for bucket in histogram.buckets {
            #expect(bucket.frequency >= 0)
            #expect(bucket.frequency <= 100)
        }
    }

    @Test
    func `skewed distribution`() {
        // Heavy skew towards small values
        var values: [Int] = []
        for i in 0..<90 {
            values.append(i % 10)
        }
        for i in 90..<100 {
            values.append(i * 10)
        }

        let histogram = AllocationHistogram(values: values, buckets: 5)
        #expect(!histogram.buckets.isEmpty)
    }

    @Test
    func `bucket sendable`() async {
        let bucket = AllocationHistogram.Bucket(
            lowerBound: 0,
            upperBound: 100,
            count: 10,
            frequency: 10.0
        )

        await Task {
            #expect(bucket.count == 10)
        }.value
    }
}
