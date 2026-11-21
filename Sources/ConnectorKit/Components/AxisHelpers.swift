import Cadova

extension DirectionalAxis where D == D3 {
    var sign: Double { axisDirection == .positive ? 1 : -1 }

    var opposite: Self {
        Self(axis: axis, towards: axisDirection == .positive ? .negative : .positive)
    }

    /// Range that starts at `start` and extends `length` in this direction.
    func span(from start: Double, length: Double) -> ClosedRange<Double> {
        let end = start + sign * length
        return min(start, end)...max(start, end)
    }
}

extension Axis3D {
    /// The third axis, which is neither `self` nor `other`.
    func third(with other: Axis3D) -> Axis3D {
        precondition(self != other, "Two different axes are required")
        return Axis3D.allCases.first { $0 != self && $0 != other }!
    }
}

extension BoundingBox3D {
    init(_ range: (Axis3D) -> ClosedRange<Double>) {
        self.init(
            minimum: Vector3D { range($0).lowerBound },
            maximum: Vector3D { range($0).upperBound }
        )
    }

    var solid: any Geometry3D {
        Box(size).translated(minimum)
    }
}
