import Memory_Allocation_Primitives
import Testing

@Suite(.serialized)
struct `Memory.Allocatable Surface Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}

    @safe
    struct Region: Memory.Growable, Memory.Allocatable, ~Copyable {
        let pointer: UnsafeMutableRawPointer

        let byteCount: Int

        init(byteCount: Memory.Address.Count, alignment: Memory.Alignment) {
            let count = Int(bitPattern: byteCount)
            self.byteCount = count
            unsafe self.pointer = UnsafeMutableRawPointer.allocate(
                byteCount: count,
                alignment: alignment.magnitude(as: Int.self)
            )
        }

        var base: Memory.Address { unsafe Memory.Address(pointer) }
        var capacity: Memory.Address.Count { Memory.Address.Count(UInt(byteCount)) }

        deinit { unsafe pointer.deallocate() }
    }
}

extension `Memory.Allocatable Surface Tests`.Unit {
    @Test func `growable constructs to the requested byte count`() {
        let region = `Memory.Allocatable Surface Tests`.Region(
            byteCount: Memory.Address.Count(UInt(256)),
            alignment: .`8`
        )
        #expect(region.capacity == Memory.Address.Count(UInt(256)))
    }

    @Test func `adopt role vends a passthrough over the whole region`() {
        let region = `Memory.Allocatable Surface Tests`.Region(
            byteCount: Memory.Address.Count(UInt(128)),
            alignment: .`8`
        )
        let allocator = region.makeAllocator()

        #expect(allocator.capacity == Memory.Address.Count(UInt(128)))
        #expect(allocator.base == allocator.base)
    }
}
