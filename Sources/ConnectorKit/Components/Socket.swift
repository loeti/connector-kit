import Cadova

/// Socket for a piece of stock, open at both ends.
///
/// It starts at distance `start` from the origin and extends `depth` in `direction`.
/// The cross-section is centered on the axis, with the stock's width along `widthAxis`.
///
/// For a standalone part, `body` is enough. When combining with other parts, first union all
/// ``outline``s and then subtract all ``negativeBody``s, so nothing protrudes into the cavities.
public struct Socket: Geometry3D {
    public let dimensions: SocketDimensions
    public let depth: Double
    public let direction: DirectionalAxis<D3>
    public let start: Double
    public let widthAxis: Axis3D
    public let screw: SocketScrew?
    public let screwPlacements: [ScrewPlacement]

    public init(
        dimensions: SocketDimensions,
        depth: Double,
        direction: DirectionalAxis<D3>,
        start: Double = 0,
        widthAxis: Axis3D? = nil,
        screw: SocketScrew? = nil,
        screwPlacements: [ScrewPlacement] = []
    ) {
        let widthAxis = widthAxis ?? Axis3D.allCases.first { $0 != direction.axis }!
        precondition(widthAxis != direction.axis, "The stock width must be perpendicular to the socket")
        precondition(
            screwPlacements.allSatisfy { $0.side.axis != direction.axis },
            "Screw holes belong on the side faces of the socket"
        )
        self.dimensions = dimensions
        self.depth = depth
        self.direction = direction
        self.start = start
        self.widthAxis = widthAxis
        self.screw = screw
        self.screwPlacements = screwPlacements
    }

    public var body: any Geometry3D {
        outline.subtracting { negativeBody }
    }

    /// Full outer shape without the cavity.
    public var outline: any Geometry3D {
        BoundingBox3D { extent(along: $0, width: dimensions.outerWidth, height: dimensions.outerHeight) }.solid
    }

    /// Cavity for the stock, plus the screw holes.
    @GeometryBuilder3D
    public var negativeBody: any Geometry3D {
        BoundingBox3D { extent(along: $0, width: dimensions.innerWidth, height: dimensions.innerHeight) }.solid

        if let screw {
            for placement in screwPlacements {
                ScrewHole(screw: screw, wallThickness: dimensions.wallThickness)
                    .rotated(from: .up, to: placement.side.opposite.direction)
                    .translated(screwHoleCenter(on: placement.side, position: placement.position))
            }
        }
    }

    /// Extent of the socket (from `start`) along a world axis.
    func extent(along axis: Axis3D, width: Double, height: Double) -> ClosedRange<Double> {
        switch axis {
        case direction.axis: direction.span(from: direction.sign * start, length: depth)
        case widthAxis: -width / 2...width / 2
        default: -height / 2...height / 2
        }
    }

    /// Center of the hole on the outer face `side`.
    func screwHoleCenter(on side: DirectionalAxis<D3>, position: Double) -> Vector3D {
        Vector3D { axis in
            switch axis {
            case direction.axis: direction.sign * (start + depth * position)
            case side.axis: side.sign * outerSize(along: axis) / 2
            default: 0
            }
        }
    }

    func outerSize(along axis: Axis3D) -> Double {
        axis == widthAxis ? dimensions.outerWidth : dimensions.outerHeight
    }
}
