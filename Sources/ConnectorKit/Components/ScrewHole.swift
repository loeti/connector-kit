import Cadova
import Helical

/// Screw hole through a wall. It enters at z = 0 and runs in +Z through `wallThickness`.
///
/// Whether the head is recessed is decided by ``SocketScrew/entry(forWallThickness:)``.
/// The clearance above the head is cut off at the surface so it doesn't cut into
/// neighbouring geometry such as other sockets or gussets.
public struct ScrewHole: Geometry3D {
    public let screw: SocketScrew
    public let wallThickness: Double

    public init(screw: SocketScrew, wallThickness: Double) {
        self.screw = screw
        self.wallThickness = wallThickness
    }

    public var body: any Geometry3D {
        screw.bolt
            .clearanceHole(depth: wallThickness, entry: screw.entry(forWallThickness: wallThickness))
            .within(z: 0...)
    }
}
