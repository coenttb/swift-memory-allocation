public import Index
public import Memory

extension Memory.Pool {

    public protocol `Protocol`: ~Copyable {

        var capacity: Memory.Pool.Count { get }

        @unsafe func pointer(at index: Index::Index<Memory.Pool.Slot>) -> UnsafeMutableRawPointer

        mutating func allocateSlot() throws(Memory.Pool.Error) -> Index::Index<Memory.Pool.Slot>

        mutating func deallocate(at slot: Index::Index<Memory.Pool.Slot>) throws(Memory.Pool.Error)
    }
}
