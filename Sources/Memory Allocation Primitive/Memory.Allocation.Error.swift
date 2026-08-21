extension Memory.Allocation {

    public enum Error: Swift.Error, Sendable, Equatable, Hashable {

        case exhausted
    }
}

extension Memory.Allocation.Error: CustomStringConvertible {

    public var description: Swift.String {
        switch self {
        case .exhausted:
            return "out of memory"
        }
    }
}
