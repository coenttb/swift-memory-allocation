public import Affine
public import Bit_Vector
public import Cardinal
public import Index
public import Memory
public import Memory_Allocator_Primitive
public import Tagged

extension Memory.Allocator where Resource: ~Copyable {

    public struct Pool: ~Copyable {

        public typealias Slot = Memory.Pool.Slot

        public typealias Error = Memory.Pool.Error

        @usableFromInline internal var backing: Resource

        @usableFromInline internal let _slotStride: Affine.Discrete.Ratio<Slot, Memory>

        @usableFromInline internal let _slotAlignment: Memory.Alignment

        @usableFromInline internal let _capacity: Tagged<Slot, Cardinal>

        @usableFromInline internal var _allocated: Tagged<Slot, Cardinal>

        @usableFromInline internal var _freeHead: Index<Slot>

        @usableFromInline internal var _nextUnused: Index<Slot>

        @usableFromInline internal var _allocationBits: Bit.Vector

        @inlinable
        public init(
            adopting backing: consuming Resource,
            slotStride: Affine.Discrete.Ratio<Slot, Memory>,
            slotAlignment: Memory.Alignment,
            capacity: Tagged<Slot, Cardinal>,
            allocated: Tagged<Slot, Cardinal>,
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
