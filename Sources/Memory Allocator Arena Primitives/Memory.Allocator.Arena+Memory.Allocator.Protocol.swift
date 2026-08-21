public import Memory_Allocator_Protocol_Primitives

extension Memory.Allocator.Arena: Memory.Allocator.`Protocol` where Resource: ~Copyable {

    @inlinable
    public mutating func allocate(
        count: Memory.Address.Count,
        alignment: Memory.Alignment
    ) throws(Self.Error) -> Memory.Address {
        let capacity = self.capacity

        let alignedCursor = alignment.align.up(cursor)

        guard let endCursor = try? alignedCursor.add.exact(count),
            endCursor <= capacity
        else {
            throw .insufficientCapacity(
                requested: count,

                available: (try? capacity.subtract.exact(alignedCursor)) ?? .zero
            )
        }

        cursor = endCursor

        return unsafe Memory.Address(
            start.mutablePointer.advanced(
                by: Memory.Address.Offset(alignedCursor)
            )
        )
    }

    @inlinable
    public mutating func deallocate(
        _ address: Memory.Address,
        count: Memory.Address.Count,
        alignment: Memory.Alignment
    ) {

    }
}
