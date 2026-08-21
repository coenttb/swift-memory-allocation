import Memory_Allocator_Primitive
public import Memory_Primitive

extension Memory.Allocator.Pool: Memory.Pool.`Protocol` where Resource: ~Copyable {}
