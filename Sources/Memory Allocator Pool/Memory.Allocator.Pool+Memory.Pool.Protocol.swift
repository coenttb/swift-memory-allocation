import Memory_Allocator_Primitive
public import Memory

extension Memory.Allocator.Pool: Memory.Pool.`Protocol` where Resource: ~Copyable {}
