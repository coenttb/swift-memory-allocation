public import Affine_Discrete
public import Bit_Vector
public import Index
public import Memory_Alignment
public import Memory_Allocator_Primitive
public import Memory_Primitive

extension Memory.Allocator where Resource: ~Copyable {

    public struct Pool: ~Copyable {

        public typealias Slot = Memory.Pool.Slot

        public typealias Error = Memory.Pool.Error

        @usableFromInline internal var backing: Resource

        @usableFromInline internal let _slotStride: Affine.Discrete.Ratio<Slot, Memory>

        @usableFromInline internal let _slotAlignment: Memory.Alignment

        @usableFromInline internal let _capacity: Index<Slot>.Count

        @usableFromInline internal var _allocated: Index<Slot>.Count

        @usableFromInline internal var _freeHead: Index<Slot>

        @usableFromInline internal var _nextUnused: Index<Slot>

        @usableFromInline internal var _allocationBits: Bit.Vector

        @inlinable
        public init(
            adopting backing: consuming Resource,
            slotStride: Affine.Discrete.Ratio<Slot, Memory>,
            slotAlignment: Memory.Alignment,
            capacity: Index<Slot>.Count,
            allocated: Index<Slot>.Count,
            freeHead: Index<Slot>,
            nextUnused: Index<Slot>,
            allocationBits: consuming Bit.Vector
        ) {
            self.backing = backing
            self._slotStride = slotStride
            self._slotAlignment = slotAlignment
            self._capacity = capacity
            self._allocated = allocated
            self._freeHead = freeHead
            self._nextUnused = nextUnused
            self._allocationBits = allocationBits
        }
    }
}
