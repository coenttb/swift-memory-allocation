# Memory Allocation

Focused allocation concepts for the Swift Atoms ecosystem.

- `Memory Allocator` defines `Memory.Allocator`.
- `Memory Allocator Protocol` defines allocation and growth protocols.
- `Memory Allocation` defines allocation metadata.
- `Memory Pool` defines fixed-slot pool identity, errors, and protocol requirements.

Consumers should depend on the narrowest product they use. The package does not expose an umbrella product.

Concrete `Memory.Allocator.Arena` and `Memory.Allocator.Pool` policies live in the
`swift-memory-allocator-arena` and `swift-memory-allocator-pool` molecule packages.
