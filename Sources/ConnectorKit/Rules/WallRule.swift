/// Rule that determines the wall thickness of a socket.
///
/// The wall is never thinner than ``minimumThickness``. If the target would result in a thinner
/// wall, the minimum is used and the socket ends up larger than the target outer size.
public struct WallRule: Sendable, Hashable {
    public enum Target: Sendable, Hashable {
        /// Fixed wall thickness; the outer size follows from it.
        case thickness(Double)
        /// Fixed outer size of the socket; the wall thickness follows from it:
        /// `wall = (outer − stock − clearance) / 2`.
        case outerSize(Double)
    }

    public static let defaultMinimumThickness = 1.2

    public var target: Target
    public var minimumThickness: Double

    public init(_ target: Target, minimumThickness: Double = Self.defaultMinimumThickness) {
        self.target = target
        self.minimumThickness = minimumThickness
    }

    /// The wall thickness the target asks for, before the minimum is applied.
    public func requestedThickness(for stock: Stock, clearance: Double) -> Double {
        switch target {
        case .thickness(let thickness):
            thickness
        case .outerSize(let outerSize):
            (outerSize - max(stock.width, stock.height) - clearance) / 2
        }
    }

    public func thickness(for stock: Stock, clearance: Double) -> Double {
        max(requestedThickness(for: stock, clearance: clearance), minimumThickness)
    }
}
