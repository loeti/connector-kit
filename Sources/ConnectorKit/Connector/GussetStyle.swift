/// Whether gussets brace the pairs of perpendicular arms.
public enum GussetStyle: Sendable, Hashable {
    case none
    /// Quarter disc around the hub corner, ending at the socket ends. Its radius reaches `overhang`
    /// beyond the socket ends, which makes the arc bulge into the corner between the arms.
    case quarterDisc(overhang: Double)
}
