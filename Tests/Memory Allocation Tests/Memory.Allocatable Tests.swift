import Memory_Allocation
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

    @Test func `arena aligns sequential allocations`() throws {
        let region = `Memory.Allocatable Surface Tests`.Region(
            byteCount: Memory.Address.Count(UInt(64)),
            alignment: .`8`
        )
        var arena = Memory.Allocator.Arena(region)

        let first = try arena.allocate(
            count: Memory.Address.Count(UInt(1)),
            alignment: .`8`
        )
        let second = try arena.allocate(
            count: Memory.Address.Count(UInt(1)),
            alignment: .`8`
        )

        #expect(first == arena.start)
        #expect(unsafe second.mutablePointer - first.mutablePointer == 8)
        #expect(arena.allocated == Memory.Address.Count(UInt(9)))
        #expect(arena.remaining == Memory.Address.Count(UInt(55)))
    }

    @Test func `pool recycles a deallocated slot`() throws {
        let region = `Memory.Allocatable Surface Tests`.Region(
            byteCount: Memory.Address.Count(UInt(64)),
            alignment: .`8`
        )
        var pool = try Memory.Allocator.Pool(
            carving: region,
            slotSize: Memory.Address.Count(UInt(16)),
            slotAlignment: .`8`
        )

        let first = try pool.allocateSlot()
        let second = try pool.allocateSlot()
        #expect(unsafe pool.pointer(at: second) - pool.pointer(at: first) == 16)

        try pool.deallocate(at: first)
        let recycled = try pool.allocateSlot()
        #expect(recycled == first)
        #expect(Int(bitPattern: pool.capacity) == 4)
        #expect(Int(bitPattern: pool.allocated) == 2)
    }
}
