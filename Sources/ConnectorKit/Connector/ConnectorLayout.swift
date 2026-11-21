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
        return configuration.passThroughAxis == axis ? 0 : configuration.stopLip.thickness
    }

    public var hub: Hub? {
        let size = Vector3D { hubLength(along: $0) }
        return size.x > 0 && size.y > 0 && size.z > 0 ? Hub(size: size) : nil
    }

    /// Openings through the hub: the full stock cross-section along the pass-through axis, or the
    /// opening of the stop lip in a straight connector.
    public var hubOpenings: [any Geometry3D] {
        let openings: [(axis: Axis3D, width: Double)] = [
            configuration.passThroughAxis.map { ($0, dimensions.innerWidth) },
            straightAxis.flatMap { axis in
                configuration.passThroughAxis == axis
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

    /// Faces of an arm that can take a screw, in order of preference. Rule: a face qualifies if it
    /// runs along the arm and isn't split by a centered gusset. A gusset that sits flush with a hub
    /// face only touches the edge of a socket face, so it leaves the middle free for the screw.
    public func screwSides(for arm: Arm) -> [DirectionalAxis<D3>] {
        Self.screwSidePreference.filter { side in
            side.axis != arm.direction.axis && !hasCenteredGusset(between: arm.direction, and: side)
        }
    }

    public func automaticScrewSide(for arm: Arm) -> DirectionalAxis<D3>? {
        screwSides(for: arm).first
    }

    /// Rule: screws alternate between the preferred face and the face opposite it (if that one is
    /// free too), spread evenly along the socket so that screws from opposite sides don't meet.
    public func screwPlacements(for arm: Arm) -> [ScrewPlacement] {
        if let screws = arm.screws { return screws }
        let count = configuration.screwsPerArm
        let candidates = screwSides(for: arm)
        guard count > 0, let preferred = candidates.first else { return [] }

        let sides = candidates.contains(preferred.opposite) ? [preferred, preferred.opposite] : [preferred]
        return ScrewPlacement.evenPositions(count: count).enumerated().map { index, position in
            ScrewPlacement(side: sides[index % sides.count], position: position)
        }
    }

    // MARK: - Gussets

    public var gussets: [Gusset] {
        gussetPlacements.map { placement in
            Gusset(
                apex: placement.apex,
                first: placement.first,
                second: placement.second,
                radius: placement.radius,
                thickness: dimensions.wallThickness
            )
        }
    }

    /// Walls that join gussets on both faces along their straight edges, beyond the sockets.
    public var gussetEdgeWalls: [GussetEdgeWall] {
        guard case .quarterDisc(_, .both) = configuration.gussets else { return [] }

        return armPairs.flatMap { first, second in
            let normal = first.axis.third(with: second.axis)
            let normalHalf = hubLength(along: normal) / 2
            let apex = apex(first: first, second: second, normalPosition: 0)
            let radius = gussetRadius(first: first, second: second)

            return [(first, second), (second, first)].map { along, inward in
                GussetEdgeWall(
                    apex: apex,
                    along: along,
                    inward: inward,
                    startDistance: hubLength(along: along.axis) + configuration.socketDepth,
                    radius: radius,
                    thickness: dimensions.wallThickness,
                    normalRange: -normalHalf...normalHalf
                )
            }
        }
    }

    // MARK: - Stock

    /// Free path for the stock along each arm, from the hub face out to where the gussets end.
    /// Gussets that reach beyond the socket would otherwise block the stock where it leaves
    /// the socket.
    public var stockChannels: [any Geometry3D] {
        let reach = gussetPlacements.map(\.radius).max() ?? 0
        return configuration.arms.map { arm in
            let start = arm.direction.sign * hubLength(along: arm.direction.axis) / 2
            return BoundingBox3D { axis in
                axis == arm.direction.axis
                    ? arm.direction.span(from: start, length: reach)
                    : -dimensions.innerWidth / 2...dimensions.innerWidth / 2
            }.solid
        }
    }

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
        let throughPiece = configuration.passThroughAxis.map { passAxis in
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
        let isCentered: Bool
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

    func gussetRadius(first: DirectionalAxis<D3>, second: DirectionalAxis<D3>) -> Double {
        guard case .quarterDisc(let overhang, _) = configuration.gussets else { return 0 }
        let reach = max(hubLength(along: first.axis), hubLength(along: second.axis)) + configuration.socketDepth
        return reach + overhang
    }

    /// Corner of the hub opposite to both arms, where the quarter disc is centered.
    func apex(first: DirectionalAxis<D3>, second: DirectionalAxis<D3>, normalPosition: Double) -> Vector3D {
        Vector3D { axis in
            switch axis {
            case first.axis: -first.sign * hubLength(along: axis) / 2
            case second.axis: -second.sign * hubLength(along: axis) / 2
            default: normalPosition
            }
        }
    }

    var gussetPlacements: [GussetPlacement] {
        guard case .quarterDisc(_, let sides) = configuration.gussets else { return [] }
        let directions = configuration.arms.map(\.direction)
        let thickness = dimensions.wallThickness

        return armPairs.flatMap { first, second in
            let normal = first.axis.third(with: second.axis)
            let normalHalf = hubLength(along: normal) / 2
            let normalDirections = Set(directions.filter { $0.axis == normal }.map(\.axisDirection))

            // Where each gusset starts along the normal axis
            let slabStarts: [Double]
            var isCentered = false
            switch sides {
            case .both:
                slabStarts = [-normalHalf, normalHalf - thickness]
            case .automatic:
                switch (normalDirections.contains(.positive), normalDirections.contains(.negative)) {
                case (true, true):
                    slabStarts = [-thickness / 2]
                    isCentered = true
                case (false, true):
                    slabStarts = [normalHalf - thickness]
                default:
                    slabStarts = [-normalHalf]
                }
            }

            let radius = gussetRadius(first: first, second: second)
            return slabStarts.map { start in
                GussetPlacement(
                    first: first,
                    second: second,
                    apex: apex(first: first, second: second, normalPosition: start),
                    radius: radius,
                    isCentered: isCentered
                )
            }
        }
    }

    func hasCenteredGusset(between arm: DirectionalAxis<D3>, and side: DirectionalAxis<D3>) -> Bool {
        gussetPlacements.contains { placement in
            placement.isCentered && Set([placement.first, placement.second]) == Set([arm, side])
        }
    }
}
