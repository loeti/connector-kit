import Cadova

/// Everything that describes a connector.
public struct ConnectorConfiguration: Sendable {
    public var socket: SocketSpec
    /// Insertion depth of each socket, measured from the hub face.
    public var socketDepth: Double
    public var arms: [Arm]
    public var screw: SocketScrew?
    /// Number of screws per arm when the layout places them.
    public var screwsPerArm: Int
    public var gussets: GussetStyle
    /// Axis along which the stock runs straight through the hub instead of stopping at it.
    public var passThroughAxis: Axis3D?
    /// Stop inside a straight connector, used when all arms lie on one axis and the stock
    /// doesn't pass through.
    public var stopLip: StopLip

    public init(
        socket: SocketSpec,
        socketDepth: Double,
        arms: [Arm],
        screw: SocketScrew? = nil,
        screwsPerArm: Int = 1,
        gussets: GussetStyle = .none,
        passThroughAxis: Axis3D? = nil,
        stopLip: StopLip = StopLip(thickness: 1, protrusion: 0.5)
    ) {
        precondition(socket.stock.isSquare, "Connectors currently support square stock only")
        precondition(Set(arms.map(\.direction)).count == arms.count, "Each direction can have only one arm")
        precondition(screwsPerArm >= 0, "The number of screws can't be negative")
        self.socket = socket
        self.socketDepth = socketDepth
        self.arms = arms
        self.screw = screw
        self.screwsPerArm = screwsPerArm
        self.gussets = gussets
        self.passThroughAxis = passThroughAxis
        self.stopLip = stopLip
    }
}
