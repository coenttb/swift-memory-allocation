public import Memory_Primitive
public import Memory_Allocator_Pool_Primitives
import Index_Primitives

extension Memory.Pool {

    public enum Laws {

        public static func violations<P: Memory.Pooling & ~Copyable>(
            makePool: () -> P,
            expectedCapacity: Int
        ) -> [String] {
            var found: [String] = []
            var pool = makePool()

            if Int(bitPattern: pool.capacity) != expectedCapacity {
                found.append("capacity: constructed \(expectedCapacity) but observes \(pool.capacity)")
            }

            var slots: [Index<Memory.Pool.Slot>] = []
            while true {
                do {
                    let slot = try pool.allocateSlot()
                    if slots.contains(slot) {
                        found.append("L1: allocateSlot handed out live slot \(slot) twice")
                    }
                    slots.append(slot)
                } catch {
                    if slots.count != expectedCapacity {
                        found.append("L4: exhausted after \(slots.count) of \(expectedCapacity) slots")
                    }
                    break
                }
                if slots.count > expectedCapacity {
                    found.append("L4: allocated past the constructed capacity")
                    break
                }
            }

            let addresses = slots.map { slot in
                unsafe Int(bitPattern: pool.pointer(at: slot))
            }
            for i in addresses.indices {
                for j in addresses.indices where i < j {
                    let distance = addresses[i] > addresses[j]
                        ? addresses[i] - addresses[j]
                        : addresses[j] - addresses[i]
                    if distance < MemoryLayout<Int>.stride {
                        found.append("L2: slots \(slots[i]) and \(slots[j]) overlap (distance \(distance))")
                    }
                }
            }

            for (ordinal, slot) in slots.enumerated() {
                unsafe pool.pointer(at: slot).storeBytes(of: ordinal &+ 1, as: Int.self)
            }

            if let churn = slots.first {
                do {
                    try pool.deallocate(at: churn)
                    let reused = try pool.allocateSlot()
                    if reused != churn {
                        found.append("L1: exhausted pool reused \(reused) for freed slot \(churn)")
                    }
                    unsafe pool.pointer(at: reused).storeBytes(of: 1, as: Int.self)
                } catch {
                    found.append("L4: churn on a proven-live slot threw \(error)")
                }
            }
            for (ordinal, slot) in slots.enumerated() {
                let address = unsafe Int(bitPattern: pool.pointer(at: slot))
                if address != addresses[ordinal] {
                    found.append("L3: slot \(slot) moved from \(addresses[ordinal]) to \(address) across unrelated ops")
                }
                let value = unsafe pool.pointer(at: slot).load(as: Int.self)
                if value != ordinal &+ 1 {
                    found.append("L5: slot \(slot) held \(value), expected \(ordinal &+ 1)")
                }
            }

            for slot in slots {
                do {
                    try pool.deallocate(at: slot)
                } catch {
                    found.append("L4: deallocate of live slot \(slot) threw \(error)")
                }
            }
            if let first = slots.first {
                do {
                    try pool.deallocate(at: first)
                    found.append("L4: double-free of \(first) did not throw")
                } catch {

                }
            }

            return found
        }
    }
}
