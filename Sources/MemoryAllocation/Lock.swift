// Lock.swift
// MemoryAllocation
//
// Cross-platform synchronization using Mutex on modern platforms, fallback to primitives

import Synchronization

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#endif

// MARK: - Modern platforms (macOS 15+, iOS 18+, etc.)

@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, *)
final class ModernLock<T>: @unchecked Sendable {
    private let mutex: Mutex<T>

    init(_ initialValue: sending T) {
        self.mutex = Mutex(initialValue)
    }

    func withLock<Result>(_ body: (inout sending T) throws -> sending Result) rethrows -> Result {
        try mutex.withLock(body)
    }
}

// MARK: - Fallback for older platforms

#if canImport(Darwin)
    final class LegacyLock: @unchecked Sendable {
        private var unfairLock = os_unfair_lock()

        init() {}

        func withLock<T>(_ body: () throws -> T) rethrows -> T {
            os_unfair_lock_lock(&unfairLock)
            defer { os_unfair_lock_unlock(&unfairLock) }
            return try body()
        }
    }
#elseif canImport(Glibc)
    final class LegacyLock: @unchecked Sendable {
        private var mutex = pthread_mutex_t()

        init() {
            pthread_mutex_init(&mutex, nil)
        }

        deinit {
            pthread_mutex_destroy(&mutex)
        }

        func withLock<T>(_ body: () throws -> T) rethrows -> T {
            pthread_mutex_lock(&mutex)
            defer { pthread_mutex_unlock(&mutex) }
            return try body()
        }
    }
#endif
