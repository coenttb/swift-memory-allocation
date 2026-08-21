extension Memory {

    public enum Allocation {}
}

extension Memory.Allocation {

    public typealias Granularity = Tagged<Memory.Allocation, Memory.Alignment>
}
