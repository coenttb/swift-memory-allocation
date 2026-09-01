public import Bit
public import Cardinal
public import Index
public import Memory
public import Memory_Allocator
public import Ordinal
public import Ordinal_Protocol
public import Tagged

@frozen
@usableFromInline
internal struct _PoolBitmap {

        @usableFromInline
        internal var words: [UInt]

        @inlinable
        internal init(capacity: Tagged<Bit, Cardinal>) {
            let bits = Int(bitPattern: capacity.underlying.rawValue)
            let count = (bits + UInt.bitWidth - 1) / UInt.bitWidth
            self.words = [UInt](repeating: 0, count: count)
        }

        @inlinable
        internal subscript(_ index: Index<Bit>) -> Bool {
            get {
                let i = Int(bitPattern: index.ordinal.rawValue)
                return words[i / UInt.bitWidth] & (1 << (i % UInt.bitWidth)) != 0
            }
            set {
                let i = Int(bitPattern: index.ordinal.rawValue)
                if newValue {
                    words[i / UInt.bitWidth] |= (1 << (i % UInt.bitWidth))
                } else {
                    words[i / UInt.bitWidth] &= ~(1 << (i % UInt.bitWidth))
                }
            }
        }

        @inlinable
        internal mutating func clearAll() {
            for i in words.indices {
                words[i] = 0
            }
        }
    }
