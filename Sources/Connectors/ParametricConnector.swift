import Cadova
import ConnectorKit
import Helical

/// Every customizer parameter of the connector model, read in one place so the model's
/// description and its geometry use the same configuration.
struct ConnectorParameters: Sendable {
    let configuration: ConnectorConfiguration
    let clearance: Double
    let showsStock: Bool

    /// Reads the parameters. Call this while a model is being built.
    static func read() -> ConnectorParameters {
        @Parameter("Stock size", in: 5...100, step: 0.5, unit: "mm", description: "Width of the square stock that goes into the sockets")
        var stockSize = 22.0

        @Parameter("Clearance", in: 0...1, step: 0.05, unit: "mm", description: "Total play between stock and socket, both sides combined. Also added to the screw holes.")
        var clearance = 0.2

        @Parameter("Socket depth", in: 5...100, step: 1, unit: "mm", description: "How far the stock goes into each socket")
        var socketDepth = 25.0

        @Parameter("Pass-through", description: "Axis along which the stock runs straight through the connector instead of stopping in the middle")
        var passThrough = PassThrough.none

        let configuration = ConnectorConfiguration(
            socket: SocketSpec(stock: Stock(size: stockSize), wallRule: wallRule),
            socketDepth: socketDepth,
            arms: arms,
            screw: screwSize.screw,
            screwsPerArm: screwsPerArm,
            gussets: gussetStyle,
            passThroughAxis: passThrough.axis
        )

        @Parameter("Show stock", description: "Show the inserted stock as reference. It isn't part of the printed model.")
        var showsStock = false

        return ConnectorParameters(configuration: configuration, clearance: clearance, showsStock: showsStock)
    }

    static var wallRule: WallRule {
        @Parameter("Wall sizing", description: "Size the sockets by their outer size, or by their wall thickness")
        var wallSizing = WallSizing.outerSize

        @Parameter("Minimum wall thickness", in: 0.4...5, step: 0.1, unit: "mm", description: "The wall is never thinner than this, even if the socket has to grow")
        var minimumThickness = WallRule.defaultMinimumThickness

        switch wallSizing {
        case .outerSize:
            @Parameter("Outer size", in: 6...120, step: 0.5, unit: "mm", description: "Outer width of each socket and of the hub")
            var outerSize = 27.0
            return WallRule(.outerSize(outerSize), minimumThickness: minimumThickness)

        case .wallThickness:
            @Parameter("Wall thickness", in: 0.4...10, step: 0.1, unit: "mm")
            var thickness = 2.4
            return WallRule(.thickness(thickness), minimumThickness: minimumThickness)
        }
    }

    static var arms: [Arm] {
        @Parameter("Arm towards +X") var positiveX = true
        @Parameter("Arm towards −X") var negativeX = false
        @Parameter("Arm towards +Y") var positiveY = true
        @Parameter("Arm towards −Y") var negativeY = false
        @Parameter("Arm towards +Z") var positiveZ = true
        @Parameter("Arm towards −Z") var negativeZ = false

        let choices: [(Bool, DirectionalAxis<D3>)] = [
            (positiveX, .maxX), (negativeX, .minX),
            (positiveY, .maxY), (negativeY, .minY),
            (positiveZ, .maxZ), (negativeZ, .minZ),
        ]
        return choices.filter(\.0).map { Arm($0.1) }
    }

    static var gussetStyle: GussetStyle {
        @Parameter("Gussets", description: "Brace each pair of perpendicular arms with a quarter-disc plate")
        var hasGussets = true

        guard hasGussets else { return .none }

        @Parameter("Gusset overhang", in: 0...50, step: 1, unit: "mm", description: "How far the gusset's arc bulges into the corner between the arms. Gussets always end at the socket ends.")
        var overhang = 8.0

        return .quarterDisc(overhang: overhang)
    }

    static var screwSize: ScrewSize {
        @Parameter("Screws", description: "Countersunk screw that secures the stock in each socket")
        var screwSize = ScrewSize.m3
        return screwSize
    }

    static var screwsPerArm: Int {
        guard screwSize != .none else { return 0 }
        @Parameter("Screws per arm", in: 1...2, description: "A second screw goes on the opposite face, offset along the socket")
        var count = 1
        return count
    }
}

/// The connector built from the customizer parameters, with the inserted stock as reference.
struct ParametricConnector: Geometry3D {
    let parameters: ConnectorParameters

    var body: any Geometry3D {
        Connector(parameters.configuration)
            .adding {
                if parameters.showsStock {
                    InsertedStock(parameters.configuration, length: 2 * parameters.configuration.socketDepth)
                        .inBackground()
                }
            }
            .withTolerance(parameters.clearance)
    }
}

enum PassThrough: String, ParameterChoice {
    case none
    case x = "X"
    case y = "Y"
    case z = "Z"

    var displayName: String {
        self == .none ? "None" : rawValue
    }

    var axis: Axis3D? {
        switch self {
        case .none: nil
        case .x: .x
        case .y: .y
        case .z: .z
        }
    }
}

enum WallSizing: String, ParameterChoice {
    case outerSize
    case wallThickness
}

enum ScrewSize: String, ParameterChoice {
    case none
    case m2 = "M2"
    case m2p5 = "M2.5"
    case m3 = "M3"
    case m4 = "M4"
    case m5 = "M5"
    case m6 = "M6"

    var displayName: String {
        self == .none ? "No screws" : rawValue
    }

    var screw: SocketScrew? {
        switch self {
        case .none: nil
        case .m2: .countersunk(.m2)
        case .m2p5: .countersunk(.m2p5)
        case .m3: .countersunk(.m3)
        case .m4: .countersunk(.m4)
        case .m5: .countersunk(.m5)
        case .m6: .countersunk(.m6)
        }
    }
}
