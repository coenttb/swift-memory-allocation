public import Cardinal
public import Memory
public import Tagged

extension Memory {

    public enum Pool {

        public enum Slot {}

        public enum Error: Swift.Error, Equatable, Sendable {

            case exhausted(capacity: Tagged<Slot, Cardinal>)

            case slotSizeTooSmall(requested: Memory.Address.Count, minimum: Memory.Address.Count)

            case invalidCapacity

            case foreignPointer

            case doubleFree
        }
    }
}
