/// Cross-section of the material that is inserted into a socket, whatever it is made of.
public struct Stock: Sendable, Hashable {
    public let width: Double
    public let height: Double

    public init(width: Double, height: Double) {
        precondition(width > 0 && height > 0, "Stock dimensions must be positive")
        self.width = width
        self.height = height
    }

    public init(size: Double) {
        self.init(width: size, height: size)
    }

    public var isSquare: Bool { width == height }
}
