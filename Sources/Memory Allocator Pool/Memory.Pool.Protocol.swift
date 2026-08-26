public import Index
public import Memory_Primitive

extension Memory.Pool {

    public protocol `Protocol`: ~Copyable {

        var capacity: Index<Memory.Pool.Slot>.Count { get }

        @unsafe func pointer(at index: Index<Memory.Pool.Slot>) -> UnsafeMutableRawPointer

        mutating func allocateSlot() throws(Memory.Pool.Error) -> Index<Memory.Pool.Slot>

        mutating func deallocate(at slot: Index<Memory.Pool.Slot>) throws(Memory.Pool.Error)
    }
}
