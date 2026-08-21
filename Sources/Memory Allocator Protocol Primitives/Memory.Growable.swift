public import Memory_Address_Primitives
public import Memory_Alignment_Primitives
public import Memory_Primitive
public import Memory_Region_Primitives

extension Memory {

    public protocol Growable: Memory.Region, ~Copyable {

        init(byteCount: Memory.Address.Count, alignment: Memory.Alignment)
    }
}
