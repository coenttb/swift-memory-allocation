public import Memory_Address_Primitives
import Memory_Alignment_Primitives
import Memory_Allocation_Primitive
public import Memory_Allocator_Primitive
public import Memory_Primitive
import Memory_Primitives_Standard_Library_Integration
public import Memory_Region_Primitives

extension Memory.Allocator where Resource: ~Copyable {

    public struct Arena: ~Copyable {

        @usableFromInline internal var backing: Resource

        @usableFromInline internal var cursor: Memory.Address.Count

        @inlinable
        public init(_ backing: consuming Resource) {
            self.backing = backing
            self.cursor = .zero
        }
    }
}

extension Memory.Allocator.Arena where Resource: ~Copyable {

    @inlinable
    public var start: Memory.Address { backing.base }

    @inlinable
    public var capacity: Memory.Address.Count { backing.capacity }

    @inlinable
    public var allocated: Memory.Address.Count { cursor }

    @inlinable
    public var remaining: Memory.Address.Count {
        capacity.subtract.saturating(cursor)
    }
}

extension Memory.Allocator.Arena where Resource: ~Copyable {

    @inlinable
    public mutating func reset() {
        cursor = .zero
    }
}

extension Memory.Allocator.Arena: @unchecked Sendable where Resource: ~Copyable & Sendable {}
