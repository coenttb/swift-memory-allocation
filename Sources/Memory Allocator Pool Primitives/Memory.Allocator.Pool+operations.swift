public import Affine_Discrete_Primitives
public import Bit_Vector_Primitives
public import Index_Primitives
public import Memory_Address_Primitives
public import Memory_Alignment_Primitives
public import Memory_Allocator_Primitive
public import Memory_Primitive
public import Memory_Primitives_Standard_Library_Integration
public import Memory_Region_Primitives

extension Memory.Allocator.Pool where Resource: ~Copyable {

    @inlinable
    public init(
        carving backing: consuming Resource,
        slotSize: Memory.Address.Count,
        slotAlignment: Memory.Alignment
    ) throws(Error) {
        let minimumSlotSize = Memory.Address.Count(UInt(MemoryLayout<Index<Slot>>.size))
        guard slotSize >= minimumSlotSize else {
            throw .slotSizeTooSmall(requested: slotSize, minimum: minimumSlotSize)
        }

        let slotStride = Affine.Discrete.Ratio<Slot, Memory>(slotAlignment.align.up(slotSize))

        let (capacity, _) = try! slotStride.quotientAndRemainder(dividing: backing.capacity)
        guard capacity > .zero else {
            throw .invalidCapacity
        }

        self.init(
            adopting: backing,
            slotStride: slotStride,
            slotAlignment: slotAlignment,
            capacity: capacity,
            allocated: .zero,
            freeHead: capacity.map(Ordinal.init),
            nextUnused: .zero,
            allocationBits: Bit.Vector(capacity: capacity.retag(Bit.self))
        )
    }
}

extension Memory.Allocator.Pool where Resource: ~Copyable {

    @inlinable
    package var _base: Memory.Address { backing.base }

    @inlinable
    package func _pointer(at index: Index<Slot>) -> UnsafeMutableRawPointer {

        unsafe _base.mutablePointer.advanced(
            by: Index<Slot>.Offset(fromZero: index) * _slotStride
        )
    }

    @inlinable
    package var _sentinel: Index<Slot> { _capacity.map(Ordinal.init) }
}

extension Memory.Allocator.Pool where Resource: ~Copyable {

    @inlinable
    public var capacity: Index<Slot>.Count { _capacity }

    @inlinable
    public var allocated: Index<Slot>.Count { _allocated }

    @inlinable
    public var available: Index<Slot>.Count {
        _capacity.subtract.saturating(_allocated)
    }

    @inlinable
    public var isExhausted: Bool {
        _freeHead == _sentinel && _nextUnused >= _sentinel
    }
}

extension Memory.Allocator.Pool where Resource: ~Copyable {

    @inlinable
    public mutating func allocateSlot() throws(Error) -> Index<Slot> {

        if _freeHead != _sentinel {
            let slot = _freeHead

            _freeHead = unsafe _pointer(at: slot).load(as: Index<Slot>.self)
            _allocationBits[slot.retag(Bit.self)] = true
            _allocated += .one
            return slot
        }

        guard _nextUnused < _sentinel else {
            throw .exhausted(capacity: _capacity)
        }

        let slot = _nextUnused
        _nextUnused += .one
        _allocationBits[slot.retag(Bit.self)] = true
        _allocated += .one
        return slot
    }

    @inlinable
    public mutating func deallocate(at slot: Index<Slot>) throws(Error) {
        let bitIndex = slot.retag(Bit.self)
        guard _allocationBits[bitIndex] else {
            throw .doubleFree
        }

        _allocationBits[bitIndex] = false

        unsafe _pointer(at: slot).storeBytes(of: _freeHead, as: Index<Slot>.self)
        _freeHead = slot
        _allocated = _allocated.subtract.saturating(.one)
    }
}

extension Memory.Allocator.Pool where Resource: ~Copyable {

    @inlinable
    public mutating func allocate() throws(Error) -> UnsafeMutableRawPointer {
        unsafe try _pointer(at: allocateSlot())
    }

    @inlinable
    public mutating func deallocate(_ pointer: UnsafeMutableRawPointer) throws(Error) {
        guard let slot = unsafe index(for: pointer) else {
            throw .foreignPointer
        }
        try deallocate(at: slot)
    }

    @inlinable
    public mutating func reset() {
        _freeHead = _sentinel
        _nextUnused = .zero
        _allocated = .zero
        _allocationBits.clear.all()
    }
}

extension Memory.Allocator.Pool where Resource: ~Copyable {

    @inlinable
    public func pointer(at index: Index<Slot>) -> UnsafeMutableRawPointer {
        precondition(index < _capacity, "Slot index out of bounds")
        return unsafe _pointer(at: index)
    }

    @inlinable
    public func index(for pointer: UnsafeMutableRawPointer) -> Index<Slot>? {

        let rawOffset = unsafe pointer - _base.mutablePointer
        guard rawOffset >= 0 else { return nil }

        let byteCount = Memory.Address.Count(UInt(rawOffset))
        guard byteCount < _capacity * _slotStride else { return nil }

        let (slotCount, remainder) = try! _slotStride.quotientAndRemainder(dividing: byteCount)
        guard remainder == .zero else { return nil }

        return slotCount.map(Ordinal.init)
    }
}

extension Memory.Allocator.Pool: @unchecked Sendable where Resource: ~Copyable & Sendable {}
