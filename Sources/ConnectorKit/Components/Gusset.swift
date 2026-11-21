import Cadova

/// Quarter-disc plate that braces the quadrant between two perpendicular arms.
///
/// The disc is centered at `apex` and opens towards `first` and `second`. The plate lies in the
/// plane spanned by both and is `thickness` thick along the third axis, starting at `apex`
/// and extending in the positive direction.
public struct Gusset: Geometry3D {
    public let apex: Vector3D
    public let first: DirectionalAxis<D3>
    public let second: DirectionalAxis<D3>
    public let radius: Double
    public let thickness: Double

    public init(apex: Vector3D, first: DirectionalAxis<D3>, second: DirectionalAxis<D3>, radius: Double, thickness: Double) {
        precondition(first.axis != second.axis, "A gusset needs two perpendicular arms")
        self.apex = apex
        self.first = first
        self.second = second
        self.radius = radius
        self.thickness = thickness
    }

    public var normal: Axis3D { first.axis.third(with: second.axis) }

    public var body: any Geometry3D {
        Cylinder(diameter: radius * 2, height: thickness)
            .rotated(from: .up, to: normal.direction(.positive))
            .translated(apex)
            .intersecting {
                // Quadrant between the two arms
                BoundingBox3D { axis in
                    switch axis {
                    case first.axis: first.span(from: apex[axis], length: radius)
                    case second.axis: second.span(from: apex[axis], length: radius)
                    default: apex[axis]...apex[axis] + thickness
                    }
                }.solid
            }
    }
}
