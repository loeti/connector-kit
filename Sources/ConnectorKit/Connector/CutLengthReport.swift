import Cadova

/// Explains in words how long to cut the stock for a connector, so the user can work out cut
/// lengths from frame dimensions measured over the connectors without measuring the model.
public struct CutLengthReport: Sendable {
    public let layout: ConnectorLayout

    public init(layout: ConnectorLayout) {
        self.layout = layout
    }

    public var text: String {
        var lines = ["Cut lengths, with frame dimensions measured over the connectors:"]

        if let ignored = layout.ignoredPassThroughAxis {
            let name = Self.name(of: ignored)
            lines.insert("Pass-through along \(name) is ignored: it needs arms in both directions along \(name), or no arms at all.", at: 0)
        }

        if let axis = layout.passThroughAxis {
            lines.append("The stock along \(Self.name(of: axis)) runs through without a stop.")
        }

        let stoppingArms = layout.configuration.arms.filter { layout.stopDistance(for: $0) != nil }
        for group in groups(of: stoppingArms) {
            lines.append("\(Self.label(for: group.arms)): \(sentence(for: group))")
        }

        // A common deduction for frames built from identical connectors
        let offsets = stoppingArms.map { layout.cutDeduction(for: $0, measuredTo: .outerFace) }
        if offsets.count > 1, let offset = offsets[0], offset > 0, offsets.allSatisfy({ $0 == offset }) {
            lines.append("Between two of these connectors, cut each stock \(Self.format(2 * offset)) mm shorter than the frame dimension.")
        }

        if lines.count == 1 {
            lines.append("There is no stock to cut.")
        }
        return lines.joined(separator: "\n")
    }

    private struct ArmGroup {
        var arms: [Arm]
        let center: Double
        let outerFace: Double?
    }

    /// Arms that share the same deductions, in their configured order.
    private func groups(of arms: [Arm]) -> [ArmGroup] {
        arms.reduce(into: [ArmGroup]()) { groups, arm in
            let center = layout.cutDeduction(for: arm, measuredTo: .center) ?? 0
            let outerFace = layout.cutDeduction(for: arm, measuredTo: .outerFace)
            if let index = groups.firstIndex(where: { $0.center == center && $0.outerFace == outerFace }) {
                groups[index].arms.append(arm)
            } else {
                groups.append(ArmGroup(arms: [arm], center: center, outerFace: outerFace))
            }
        }
    }

    private func sentence(for group: ArmGroup) -> String {
        if group.center == 0, group.outerFace == nil {
            return "the stocks meet at a stop lip within the cutting tolerance, so together they are cut to the total length."
        }
        var sentence = "the stock ends \(Self.format(group.center)) mm from the connector's center"
        if let outerFace = group.outerFace {
            sentence += " and \(Self.format(outerFace)) mm from its outer face"
        }
        return sentence + "."
    }

    static func label(for arms: [Arm]) -> String {
        let names = arms.map { arm in
            (arm.direction.axisDirection == .positive ? "+" : "−") + name(of: arm.direction.axis)
        }
        return (arms.count == 1 ? "Arm " : "Arms ") + names.joined(separator: ", ")
    }

    static func name(of axis: Axis3D) -> String {
        ["X", "Y", "Z"][axis.index]
    }

    /// Formats a length to at most one decimal, without a trailing ".0". Avoids number
    /// formatters, which aren't available when the model runs in a browser.
    static func format(_ length: Double) -> String {
        let tenths = Int((length * 10).rounded())
        return tenths % 10 == 0 ? "\(tenths / 10)" : "\(tenths / 10).\(tenths % 10)"
    }
}
