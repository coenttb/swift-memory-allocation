public import Memory

extension Memory {

    public protocol Growable: Memory.Region, ~Copyable {

        init(byteCount: Memory.Address.Count, alignment: Memory.Alignment)
    }
}
