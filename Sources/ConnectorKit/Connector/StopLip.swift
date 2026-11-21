/// Thin ring inside a straight connector that stops the stock halfway, instead of a solid hub.
public struct StopLip: Sendable, Hashable {
    /// Length of the lip along the connector.
    public var thickness: Double
    /// How far the lip reaches into the cavity from each wall.
    public var protrusion: Double

    public init(thickness: Double, protrusion: Double) {
        self.thickness = thickness
        self.protrusion = protrusion
    }
}
