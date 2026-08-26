public import Memory_Address
import Memory_Alignment
public import Memory_Primitive
public import Memory_Region

extension Memory {

    public struct Allocator<Resource: ~Copyable & Memory.Region>: ~Copyable {

        @usableFromInline
        internal var resource: Resource

        @inlinable
        public init(_ resource: consuming Resource) {
            self.resource = resource
        }
    }
}

extension Memory.Allocator: Memory.Region where Resource: ~Copyable {

    @inlinable
    public var base: Memory.Address { resource.base }

    @inlinable
    public var capacity: Memory.Address.Count { resource.capacity }
}

extension Memory.Allocator: @unchecked Sendable where Resource: ~Copyable & Sendable {}
