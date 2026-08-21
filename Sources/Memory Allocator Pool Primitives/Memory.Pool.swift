public import Index_Primitives
public import Memory_Address_Primitives
public import Memory_Primitive

extension Memory {

    public enum Pool {

        public enum Slot {}

        public enum Error: Swift.Error, Equatable, Sendable {

            case exhausted(capacity: Index<Slot>.Count)

            case slotSizeTooSmall(requested: Memory.Address.Count, minimum: Memory.Address.Count)

            case invalidCapacity

            case foreignPointer

            case doubleFree
        }
    }
}
