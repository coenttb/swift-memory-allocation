public import Cardinal
import Index
public import Memory
public import Tagged

extension Memory {

    public enum Pool {

        public enum Slot {}

        public typealias Count = Tagged::Tagged<Slot, Cardinal::Cardinal>

        public enum Error: Swift.Error, Equatable, Sendable {

            case exhausted(capacity: Count)

            case slotSizeTooSmall(requested: Memory.Address.Count, minimum: Memory.Address.Count)

            case invalidCapacity

            case foreignPointer

            case doubleFree
        }
    }
}
