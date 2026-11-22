import Cadova

/// Resolves a ``ConnectorConfiguration`` into concrete components: hub, sockets, gussets and
/// the openings for the stock. The hub is centered at the origin.
public struct ConnectorLayout: Sendable {
    public let configuration: ConnectorConfiguration
    public let dimensions: SocketDimensions

    /// Faces tried in this order when an arm doesn't specify where its screws go:
    /// the top first, then the faces towards the back and right, then the rest.
    public static let screwSidePreference: [DirectionalAxis<D3>] = [.maxZ, .maxY, .maxX, .minY, .minX, .minZ]

    public init(configuration: ConnectorConfiguration, clearance: Double) {
        self.configuration = configuration
        self.dimensions = configuration.socket.dimensions(clearance: clearance)
    }

    // MARK: - Pass-through

    /// The pass-through axis that applies. Rule: stock only runs through along an axis with arms in
    /// both directions, so sockets guide it on both sides, or along any axis of a connector without
    /// arms (a reducing sleeve). Any other configured axis is ignored.
    public var passThroughAxis: Axis3D? {
        guard let axis = configuration.passThroughAxis else { return nil }
        let directions = Set(configuration.arms.filter { $0.direction.axis == axis }.map(\.direction.axisDirection))
        return configuration.arms.isEmpty || directions.count == 2 ? axis : nil
    }

    /// The configured pass-through axis if it was ignored, so the user can be told why.
    public var ignoredPassThroughAxis: Axis3D? {
        passThroughAxis == nil ? configuration.passThroughAxis : nil
    }

    // MARK: - Hub

    /// The axis shared by all arms, if they all lie on one axis.
    public var straightAxis: Axis3D? {
        let axes = Set(configuration.arms.map(\.direction.axis))
        return axes.count == 1 ? axes.first : nil
    }

    /// Size of the hub along an axis. Rule: a straight connector has no hub, only the stop lip,
    /// or nothing at all if the stock passes through. Otherwise the hub is a cube as wide as a socket.
    public func hubLength(along axis: Axis3D) -> Double {
        guard axis == straightAxis else { return dimensions.outerWidth }
        return passThroughAxis == axis ? 0 : configuration.stopLip.thickness
    }

    public var hub: Hub? {
        let size = Vector3D { hubLength(along: $0) }
        return size.x > 0 && size.y > 0 && size.z > 0 ? Hub(size: size) : nil
    }

    /// Openings through the hub: the full stock cross-section along the pass-through axis, or the
    /// opening of the stop lip in a straight connector.
    public var hubOpenings: [any Geometry3D] {
        let openings: [(axis: Axis3D, width: Double)] = [
            passThroughAxis.map { ($0, dimensions.innerWidth) },
            straightAxis.flatMap { axis in
                passThroughAxis == axis
                    ? nil
                    : (axis, dimensions.innerWidth - 2 * configuration.stopLip.protrusion)
            },
        ].compactMap { $0 }

        return openings.map { opening in
            let length = hubLength(along: opening.axis)
            return BoundingBox3D { axis in
                axis == opening.axis ? -length / 2...length / 2 : -opening.width / 2...opening.width / 2
            }.solid
        }
    }

    // MARK: - Cut lengths

    /// Stock is cut to whole millimetres at best, so smaller deductions count as zero.
    public static let cuttingTolerance = 1.0

    /// Distance from the connector's center to the end of the stock in an arm: half the hub
    /// (or half the stop lip). `nil` if the stock passes through along the arm's axis.
    public func stopDistance(for arm: Arm) -> Double? {
        guard passThroughAxis != arm.direction.axis else { return nil }
        return hubLength(along: arm.direction.axis) / 2
    }

    /// Distance from the connector's outer face opposite an arm to the end of the stock in that
    /// arm: the whole hub. `nil` if the opposite direction has an arm (there is no outer face) or
    /// the stock passes through.
    public func outerOffset(for arm: Arm) -> Double? {
        let opposite = arm.direction.opposite
        guard let stop = stopDistance(for: arm),
              !configuration.arms.contains(where: { $0.direction == opposite })
        else { return nil }
        return stop + hubLength(along: arm.direction.axis) / 2
    }

    /// Where a frame dimension is measured to at a connector.
    public enum Reference: Sendable {
        /// Over the outside of the connector.
        case outerFace
        /// To the connector's center, such as for a tee within a side.
        case center
    }

    /// Length to subtract from a frame dimension at this end of a stock. Rule: deductions below
    /// the cutting tolerance count as zero, which makes the stop lip of an extension free.
    public func cutDeduction(for arm: Arm, measuredTo reference: Reference) -> Double? {
        let deduction = switch reference {
        case .outerFace: outerOffset(for: arm)
        case .center: stopDistance(for: arm)
        }
        return deduction.map { $0 < Self.cuttingTolerance ? 0 : $0 }
    }

    // MARK: - Sockets and screws

    public var sockets: [Socket] {
        configuration.arms.map { arm in
            Socket(
                dimensions: dimensions,
                depth: configuration.socketDepth,
                direction: arm.direction,
                start: hubLength(along: arm.direction.axis) / 2,
                screw: configuration.screw,
                screwPlacements: screwPlacements(for: arm)
            )
        }
    }

    /// Faces of an arm that can take a screw, in order of preference: every face along the arm.
    /// Gussets don't block a face, because they sit flush with a hub face and only touch the edge
    /// of a socket face.
    public func screwSides(for arm: Arm) -> [DirectionalAxis<D3>] {
        Self.screwSidePreference.filter { $0.axis != arm.direction.axis }
    }

    public func automaticScrewSide(for arm: Arm) -> DirectionalAxis<D3>? {
        screwSides(for: arm).first
    }

    public func screwPlacements(for arm: Arm) -> [ScrewPlacement] {
        arm.screws ?? screwPlacements(on: screwSides(for: arm))
    }

    /// Rule: screws alternate between the preferred face and the face opposite it (if that one is
    /// free too), spread evenly along the socket so that screws from opposite sides don't meet.
    func screwPlacements(on candidates: [DirectionalAxis<D3>]) -> [ScrewPlacement] {
        let count = configuration.screwsPerArm
        guard count > 0, let preferred = candidates.first else { return [] }

        let sides = candidates.contains(preferred.opposite) ? [preferred, preferred.opposite] : [preferred]
        return ScrewPlacement.evenPositions(count: count).enumerated().map { index, position in
            ScrewPlacement(side: sides[index % sides.count], position: position)
        }
    }

    /// The hub seen as a socket along the pass-through axis. Rule: in a connector without arms
    /// (a reducing sleeve) nothing else holds the stock that runs through, so the hub gets screws
    /// of its own. With arms, a valid pass-through has arms on both sides that hold it.
    public var passThroughHubSocket: Socket? {
        guard configuration.arms.isEmpty, let axis = passThroughAxis, let hub else { return nil }
        let direction = DirectionalAxis<D3>(axis: axis, towards: .positive)

        return Socket(
            dimensions: dimensions,
            depth: hub.size[axis],
            direction: direction,
            start: -hub.size[axis] / 2,
            screw: configuration.screw,
            screwPlacements: screwPlacements(on: screwSides(for: Arm(direction)))
        )
    }

    // MARK: - Gussets

    public var gussets: [Gusset] {
        gussetPlacements.map { placement in
            Gusset(
                apex: placement.apex,
                first: placement.first,
                second: placement.second,
                radius: placement.radius,
                reach: placement.reach,
                thickness: dimensions.wallThickness
            )
        }
    }

    // MARK: - Stock

    /// The inserted stock, as a reference for display and fit tests. Each piece butts against
    /// the hub (or runs through it along the pass-through axis) and sticks out `length`.
    public func stockPieces(length: Double) -> [any Geometry3D] {
        let half = dimensions.stock.width / 2
        let pieces = configuration.arms.map { arm in
            let start = arm.direction.sign * hubLength(along: arm.direction.axis) / 2
            return BoundingBox3D { axis in
                axis == arm.direction.axis ? arm.direction.span(from: start, length: length) : -half...half
            }.solid
        }
        let throughPiece = passThroughAxis.map { passAxis in
            let hubHalf = hubLength(along: passAxis) / 2
            return BoundingBox3D { $0 == passAxis ? -hubHalf...hubHalf : -half...half }.solid
        }
        return pieces + [throughPiece].compactMap { $0 }
    }
}

private extension ConnectorLayout {
    struct GussetPlacement {
        let first: DirectionalAxis<D3>
        let second: DirectionalAxis<D3>
        let apex: Vector3D
        let radius: Double
        let reach: Double
    }

    /// Every pair of perpendicular arms.
    var armPairs: [(DirectionalAxis<D3>, DirectionalAxis<D3>)] {
        let directions = configuration.arms.map(\.direction)
        return directions.indices.flatMap { i in
            directions[(i + 1)...]
                .filter { $0.axis != directions[i].axis }
                .map { (directions[i], $0) }
        }
    }

    /// Rule: one gusset per pair of perpendicular arms, flush with the hub face along the third
    /// axis that has no arm (the − face if neither has one). A pair whose third axis has arms in
    /// both directions gets none, because a gusset in the middle would split the space between
    /// the arms. Each gusset ends at the socket ends; the overhang only makes its arc bulge.
    var gussetPlacements: [GussetPlacement] {
        guard case .quarterDisc(let overhang) = configuration.gussets else { return [] }
        let directions = configuration.arms.map(\.direction)
        let thickness = dimensions.wallThickness

        return armPairs.compactMap { first, second in
            let normal = first.axis.third(with: second.axis)
            let normalHalf = hubLength(along: normal) / 2
            let normalDirections = Set(directions.filter { $0.axis == normal }.map(\.axisDirection))

            let slabStart: Double
            switch (normalDirections.contains(.positive), normalDirections.contains(.negative)) {
            case (true, true): return nil
            case (false, true): slabStart = normalHalf - thickness
            default: slabStart = -normalHalf
            }

            let apex = Vector3D { axis in
                switch axis {
                case first.axis: -first.sign * hubLength(along: axis) / 2
                case second.axis: -second.sign * hubLength(along: axis) / 2
                default: slabStart
                }
            }
            let reach = max(hubLength(along: first.axis), hubLength(along: second.axis)) + configuration.socketDepth
            return GussetPlacement(first: first, second: second, apex: apex, radius: reach + overhang, reach: reach)
        }
    }
}
