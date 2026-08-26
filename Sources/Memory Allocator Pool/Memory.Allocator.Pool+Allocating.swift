public import Memory_Address
public import Memory_Alignment
public import Memory_Allocator_Protocol
public import Memory_Primitive

extension Memory.Allocator.Pool: Memory.Allocator.`Protocol` where Resource: ~Copyable {

    @inlinable
    public mutating func allocate(
        count: Memory.Address.Count,
        alignment: Memory.Alignment
    ) throws(Error) -> Memory.Address {

        let pointer = unsafe try allocate()
        return unsafe Memory.Address(pointer)
    }

    @inlinable
    public mutating func deallocate(
        _ address: Memory.Address,
        count: Memory.Address.Count,
        alignment: Memory.Alignment
    ) {

        do throws(Error) {
            unsafe try deallocate(UnsafeMutableRawPointer(address))
        } catch {

        }
    }
}
