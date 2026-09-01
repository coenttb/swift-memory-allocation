public import Affine_Discrete
public import Bit
public import Index
public import Memory
public import Memory_Allocator
public import Memory_Pool

extension Memory.Allocator where Resource: ~Copyable {

    public struct Pool: ~Copyable {

        public typealias Slot = Memory.Pool.Slot

        public typealias Error = Memory.Pool.Error

        @usableFromInline internal var backing: Resource

        @usableFromInline internal let _slotStride: Affine.Discrete.Ratio<Slot, Memory>

        @usableFromInline internal let _slotAlignment: Memory.Alignment

        @usableFromInline internal let _capacity: Memory.Pool.Count

        @usableFromInline internal var _allocated: Memory.Pool.Count

        @usableFromInline internal var _freeHead: Index<Slot>

        @usableFromInline internal var _nextUnused: Index<Slot>

        @usableFromInline internal var _allocationBits: _PoolBitmap

        @usableFromInline
        internal init(
            adopting backing: consuming Resource,
            slotStride: Affine.Discrete.Ratio<Slot, Memory>,
            slotAlignment: Memory.Alignment,
            capacity: Memory.Pool.Count,
            allocated: Memory.Pool.Count,
            freeHead: Index<Slot>,
            nextUnused: Index<Slot>,
            allocationBits: consuming _PoolBitmap
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
