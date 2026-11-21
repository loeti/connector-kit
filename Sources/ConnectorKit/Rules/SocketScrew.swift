import Cadova
import Helical

/// Screw that secures the stock in its socket.
public struct SocketScrew: Sendable {
    public var bolt: Bolt

    public init(_ bolt: Bolt) {
        self.bolt = bolt
    }

    /// Rule: recess the head only if the wall is at least as thick as the head is tall.
    /// Otherwise the countersink would break through the wall, so a plain through hole is used.
    public func entry(forWallThickness wallThickness: Double) -> Bolt.ClearanceHoleEntry {
        wallThickness >= bolt.headShape.height ? .recessedHead : .plain
    }
}

public extension SocketScrew {
    /// Hex socket countersunk screw to ISO 10642 / DIN 7991. Its head is twice the thread
    /// diameter, which also matches common countersunk wood screws of the same diameter.
    static func countersunk(_ size: ScrewThread.ISOMetricSize) -> SocketScrew {
        SocketScrew(.hexSocketCountersunk(size, length: 16))
    }
}
