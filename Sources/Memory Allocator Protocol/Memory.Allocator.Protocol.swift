public import Memory_Address
public import Memory_Alignment
public import Memory_Allocator_Primitive
public import Memory_Primitive

public protocol __MemoryAllocatorProtocol: ~Copyable {

    associatedtype Error: Swift.Error

    mutating func allocate(
        count: Memory.Address.Count,
        alignment: Memory.Alignment
    ) throws(Self.Error) -> Memory.Address

    mutating func deallocate(
        _ address: Memory.Address,
        count: Memory.Address.Count,
        alignment: Memory.Alignment
    )
}

extension Memory.Allocator where Resource: ~Copyable {

    public typealias `Protocol` = __MemoryAllocatorProtocol
}
