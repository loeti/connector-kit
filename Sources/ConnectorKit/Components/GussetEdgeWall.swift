import Cadova

/// Wall along a straight edge of a quarter-disc gusset, from the end of a socket out to the rim.
///
/// It continues the back wall of the socket that runs along `along`, so two gussets on opposite
/// faces form a closed edge there. The wall lies against the edge at `apex` (the quadrant opens
/// towards `inward`), is `thickness` thick and spans `normalRange` along the remaining axis.
public struct GussetEdgeWall: Geometry3D {
    public let apex: Vector3D
    public let along: DirectionalAxis<D3>
    public let inward: DirectionalAxis<D3>
    /// Distance from `apex` along `along` where the wall starts (the end of the socket).
    public let startDistance: Double
    public let radius: Double
    public let thickness: Double
    public let normalRange: ClosedRange<Double>

    public init(
        apex: Vector3D,
        along: DirectionalAxis<D3>,
        inward: DirectionalAxis<D3>,
        startDistance: Double,
        radius: Double,
        thickness: Double,
        normalRange: ClosedRange<Double>
    ) {
        precondition(along.axis != inward.axis, "The wall runs along one edge of the quadrant")
        self.apex = apex
        self.along = along
        self.inward = inward
        self.startDistance = startDistance
        self.radius = radius
        self.thickness = thickness
        self.normalRange = normalRange
    }

    public var body: any Geometry3D {
        let normal = along.axis.third(with: inward.axis)
        let height = normalRange.upperBound - normalRange.lowerBound

        BoundingBox3D { axis in
            switch axis {
            case along.axis: along.span(from: apex[axis] + along.sign * startDistance, length: radius - startDistance)
            case inward.axis: inward.span(from: apex[axis], length: thickness)
            default: normalRange
            }
        }
        .solid
        .intersecting {
            // Ends at the rim of the gusset
            Cylinder(diameter: radius * 2, height: height)
                .rotated(from: .up, to: normal.direction(.positive))
                .translated(Vector3D { $0 == normal ? normalRange.lowerBound : apex[$0] })
        }
    }
}
