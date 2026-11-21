/// Which stock goes into a socket and which rule sizes the socket's wall.
public struct SocketSpec: Sendable, Hashable {
    public var stock: Stock
    public var wallRule: WallRule

    public init(stock: Stock, wallRule: WallRule) {
        self.stock = stock
        self.wallRule = wallRule
    }

    /// - Parameter clearance: Total clearance between stock and socket (both sides combined),
    ///   usually the `tolerance` from the Cadova environment.
    public func dimensions(clearance: Double) -> SocketDimensions {
        SocketDimensions(
            stock: stock,
            clearance: clearance,
            wallThickness: wallRule.thickness(for: stock, clearance: clearance),
            isWallAtMinimum: wallRule.requestedThickness(for: stock, clearance: clearance) < wallRule.minimumThickness
        )
    }
}
