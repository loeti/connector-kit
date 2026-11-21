import Cadova

/// One arm of a connector: a socket pointing along an axis direction.
public struct Arm: Sendable, Hashable {
    public var direction: DirectionalAxis<D3>
    /// Screw holes of this arm. `nil` lets ``ConnectorLayout`` place them.
    public var screws: [ScrewPlacement]?

    public init(_ direction: DirectionalAxis<D3>, screws: [ScrewPlacement]? = nil) {
        self.direction = direction
        self.screws = screws
    }
}
