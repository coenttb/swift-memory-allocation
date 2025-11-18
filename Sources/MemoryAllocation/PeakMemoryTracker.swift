// PeakMemoryTracker.swift
// MemoryAllocation
//
// Peak memory usage tracking

/// Peak memory tracker
///
/// Tracks the peak memory usage during program execution.
///
/// Example:
/// ```swift
/// let tracker = PeakMemoryTracker()
///
/// for i in 0..<100 {
///     let array = Array(repeating: 0, count: i * 100)
///     tracker.sample()
/// }
///
/// print("Peak memory: \(tracker.peakBytes) bytes")
/// print("Peak allocations: \(tracker.peakAllocations)")
/// ```
public final class PeakMemoryTracker: Sendable {
    private struct State {
        var peakBytes: Int = 0
        var peakAllocations: Int = 0
        var samples: [AllocationStats] = []
    }

    private let state: any LockProtocol<State>
    private let baseline: AllocationStats

    private protocol LockProtocol<T>: Sendable {
        associatedtype T
        func withLock<Result>(_ body: (inout sending T) throws -> sending Result) rethrows -> Result
    }

    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, *)
    private final class Modern: LockProtocol, @unchecked Sendable {
        private let lock: ModernLock<State>
        init(_ value: State) { self.lock = ModernLock(value) }
        func withLock<Result>(
            _ body: (inout sending State) throws -> sending Result
        ) rethrows -> Result {
            try lock.withLock(body)
        }
    }

    private final class Legacy: LockProtocol, @unchecked Sendable {
        private let lock = LegacyLock()
        private var value: State
        init(_ value: State) { self.value = value }
        func withLock<Result>(
            _ body: (inout sending State) throws -> sending Result
        ) rethrows -> Result {
            try lock.withLock { try body(&value) }
        }
    }

    /// Initialize a peak memory tracker
    public init() {
        #if os(Linux)
            AllocationStats.startTracking()
        #endif

        if #available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, *) {
            self.state = Modern(State())
        } else {
            self.state = Legacy(State())
        }

        self.baseline = AllocationStats.capture()
    }

    /// Record a sample of current memory usage
    ///
    /// Call this periodically to track peak memory.
    public func sample() {
        let current = AllocationStats.capture()
        let delta = AllocationStats.delta(from: baseline, to: current)

        state.withLock { state in
            state.samples.append(delta)
            state.peakBytes = max(state.peakBytes, delta.bytesAllocated)
            state.peakAllocations = max(state.peakAllocations, delta.allocations)
        }
    }

    /// Peak bytes allocated since initialization
    public var peakBytes: Int {
        state.withLock { $0.peakBytes }
    }

    /// Peak number of allocations since initialization
    public var peakAllocations: Int {
        state.withLock { $0.peakAllocations }
    }

    /// All samples collected
    public var samples: [AllocationStats] {
        state.withLock { $0.samples }
    }

    /// Current memory usage
    public var current: AllocationStats {
        let current = AllocationStats.capture()
        return AllocationStats.delta(from: baseline, to: current)
    }

    /// Reset peak tracking
    ///
    /// Clears samples and resets peak values to current state.
    public func reset() {
        state.withLock { state in
            state.samples.removeAll()
            state.peakBytes = 0
            state.peakAllocations = 0
        }
    }

    /// Track peak memory during an operation
    ///
    /// Samples memory at regular intervals during the operation.
    ///
    /// - Parameters:
    ///   - sampleInterval: Number of iterations between samples
    ///   - operation: The operation to track
    /// - Returns: Peak allocation statistics and operation result
    public static func track<T>(
        sampleInterval: Int = 1,
        _ operation: (PeakMemoryTracker) throws -> T
    ) rethrows -> (result: T, peak: AllocationStats) {
        let tracker = PeakMemoryTracker()
        let result = try operation(tracker)

        return (
            result,
            AllocationStats(
                allocations: tracker.peakAllocations,
                deallocations: 0,
                bytesAllocated: tracker.peakBytes
            )
        )
    }

    /// Track peak memory during an async operation
    ///
    /// - Parameters:
    ///   - sampleInterval: Number of iterations between samples
    ///   - operation: The async operation to track
    /// - Returns: Peak allocation statistics and operation result
    public static func track<T>(
        sampleInterval: Int = 1,
        _ operation: (PeakMemoryTracker) async throws -> T
    ) async rethrows -> (result: T, peak: AllocationStats) {
        let tracker = PeakMemoryTracker()
        let result = try await operation(tracker)

        return (
            result,
            AllocationStats(
                allocations: tracker.peakAllocations,
                deallocations: 0,
                bytesAllocated: tracker.peakBytes
            )
        )
    }
}
