/// Whether and how gussets are placed between perpendicular arms.
public enum GussetStyle: Sendable, Hashable {
    case none
    /// Quarter disc around the hub corner. Its radius reaches `overhang` beyond the socket ends.
    case quarterDisc(overhang: Double, sides: GussetSides)
}

/// Where gussets sit along the axis perpendicular to the two arms they brace.
///
/// Gussets are as thick as the socket wall and sit flush with a face of the hub.
public enum GussetSides: Sendable, Hashable {
    /// One gusset per pair of arms:
    /// - If the connector has an arm on the third axis only in the + direction, the gusset sits on
    ///   the − side (and vice versa). This gives a corner connector its flat back faces.
    /// - Without an arm on the third axis, it sits on the − side, giving a flat bottom for printing.
    /// - With arms in both directions, it sits in the middle.
    case automatic
    /// Gussets on both faces of the hub, joined by walls along their straight edges beyond the
    /// sockets. This closes the connector into a box section between the arms.
    case both
}
