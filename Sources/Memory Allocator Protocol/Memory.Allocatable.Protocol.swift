public import Memory_Allocator_Primitive
public import Memory_Primitive
public import Memory_Region

public protocol __MemoryAllocatableProtocol: Memory.Region, ~Copyable {

    consuming func makeAllocator() -> Memory.Allocator<Self>
}

extension __MemoryAllocatableProtocol where Self: ~Copyable {

    @inlinable
    public consuming func makeAllocator() -> Memory.Allocator<Self> {
        Memory.Allocator(self)
    }
}
