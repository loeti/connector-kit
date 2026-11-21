import Cadova

/// Solid core that the sockets attach to, centered at the origin.
/// It also acts as the end stop for the inserted stock.
public struct Hub: Geometry3D {
    public let size: Vector3D

    public init(size: Vector3D) {
        self.size = size
    }

    public var body: any Geometry3D {
        Box(size).aligned(at: .center)
    }
}
