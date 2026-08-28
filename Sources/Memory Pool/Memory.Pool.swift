public import Index
public import Memory

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
