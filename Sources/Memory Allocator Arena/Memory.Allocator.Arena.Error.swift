public import Memory
public import Memory_Allocation_Primitive

extension Memory.Allocator.Arena where Resource: ~Copyable {

    public enum Error: Swift.Error, Equatable, Sendable {

        case insufficientCapacity(requested: Memory.Address.Count, available: Memory.Address.Count)
    }
}
