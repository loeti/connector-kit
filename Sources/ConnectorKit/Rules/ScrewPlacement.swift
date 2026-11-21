import Cadova

/// Where a screw goes on a socket: which side face, and how far along the socket.
public struct ScrewPlacement: Sendable, Hashable {
    public var side: DirectionalAxis<D3>
    /// Position along the socket, as a fraction of the socket depth (0.5 = middle).
    public var position: Double

    public init(side: DirectionalAxis<D3>, position: Double = 0.5) {
        precondition((0...1).contains(position), "The screw position is a fraction of the socket depth (0…1)")
        self.side = side
        self.position = position
    }

    /// Positions along the socket for a number of screws, spread evenly so that screws entering
    /// from opposite sides don't meet: one in the middle, two at a third and two thirds, and so on.
    public static func evenPositions(count: Int) -> [Double] {
        (1...max(count, 1)).map { Double($0) / Double(count + 1) }
    }
}
