public import Cardinal
public import Index
public import Memory
public import Tagged

extension Memory.Pool {

    public protocol `Protocol`: ~Copyable {

        var capacity: Tagged<Memory.Pool.Slot, Cardinal> { get }

        @unsafe func pointer(at index: Index<Memory.Pool.Slot>) -> UnsafeMutableRawPointer

        mutating func allocateSlot() throws(Memory.Pool.Error) -> Index<Memory.Pool.Slot>

        mutating func deallocate(at slot: Index<Memory.Pool.Slot>) throws(Memory.Pool.Error)
    }
}
