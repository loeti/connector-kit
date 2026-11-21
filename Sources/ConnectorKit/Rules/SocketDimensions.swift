/// Resolved dimensions of a socket: stock + clearance + wall.
public struct SocketDimensions: Sendable, Hashable {
    public let stock: Stock
    /// Total clearance (both sides combined).
    public let clearance: Double
    public let wallThickness: Double
    /// `true` if the rule asked for a thinner wall and the minimum was used instead.
    public let isWallAtMinimum: Bool

    public var innerWidth: Double { stock.width + clearance }
    public var innerHeight: Double { stock.height + clearance }
    public var outerWidth: Double { innerWidth + 2 * wallThickness }
    public var outerHeight: Double { innerHeight + 2 * wallThickness }
}
