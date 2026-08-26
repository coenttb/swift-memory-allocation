public import Memory_Address
public import Memory_Alignment
public import Memory_Primitive
public import Memory_Region

extension Memory {

    public protocol Growable: Memory.Region, ~Copyable {

        init(byteCount: Memory.Address.Count, alignment: Memory.Alignment)
    }
}
