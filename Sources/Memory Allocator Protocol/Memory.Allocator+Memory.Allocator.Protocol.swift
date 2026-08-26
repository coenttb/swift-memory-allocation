public import Memory_Address
public import Memory_Alignment
public import Memory_Allocator_Primitive
public import Memory_Primitive

extension Memory.Allocator: __MemoryAllocatorProtocol where Resource: ~Copyable {

    public typealias Error = Never

    @inlinable
    public mutating func allocate(
        count: Memory.Address.Count,
        alignment: Memory.Alignment
    ) throws(Never) -> Memory.Address {
        precondition(
            count <= capacity,
            "passthrough allocator: requested byte count exceeds the adopted region's capacity"
        )
        return base
    }

    @inlinable
    public mutating func deallocate(
        _ address: Memory.Address,
        count: Memory.Address.Count,
        alignment: Memory.Alignment
    ) {

    }
}
