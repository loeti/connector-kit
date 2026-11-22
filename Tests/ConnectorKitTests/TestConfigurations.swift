import Testing
import Cadova
@testable import ConnectorKit

/// The reference design: 22 mm stock in 27 mm sockets, 25 mm deep, M3 screws, 8 mm gusset overhang.
func referenceConfiguration(
    _ directions: [DirectionalAxis<D3>],
    gussets: GussetStyle = .quarterDisc(overhang: 8, sides: .automatic),
    screwsPerArm: Int = 1,
    passThroughAxis: Axis3D? = nil
) -> ConnectorConfiguration {
    ConnectorConfiguration(
        socket: SocketSpec(stock: Stock(size: 22), wallRule: WallRule(.outerSize(27))),
        socketDepth: 25,
        arms: directions.map { Arm($0) },
        screw: .countersunk(.m3),
        screwsPerArm: screwsPerArm,
        gussets: gussets,
        passThroughAxis: passThroughAxis
    )
}

// MARK: - Target constructions (openspec/specs/target-constructions)

/// No arms, stock passing through along X: a sleeve that adapts 13 mm stock to a 22 mm socket.
let reducingSleeve = ConnectorConfiguration(
    socket: SocketSpec(stock: Stock(size: 13), wallRule: WallRule(.outerSize(22))),
    socketDepth: 25,
    arms: [],
    screw: .countersunk(.m3),
    passThroughAxis: .x
)
/// Two arms on one axis with a stop lip in between, two screws per arm.
let extensionOfTwoStocks = referenceConfiguration([.minY, .maxY], screwsPerArm: 2)
/// Three stocks, all ending at the hub.
let teeJoiningThreeStocks = referenceConfiguration([.minX, .maxX, .maxY])
/// A stock running through along X, with a perpendicular stock towards −Y.
let teeJoiningPerpendicularStock = referenceConfiguration([.minX, .maxX, .minY], gussets: .none, passThroughAxis: .x)
let cornerWithTwoStocks = referenceConfiguration([.maxX, .maxY])
/// Closed by gussets on both faces and walls along their edges.
let boxedCornerWithTwoStocks = referenceConfiguration([.maxX, .maxY], gussets: .quarterDisc(overhang: 8, sides: .both))
let cornerWithThreeStocks = referenceConfiguration([.maxX, .maxY, .maxZ])

/// A target construction with the bounding box its spec requires.
struct TargetConstruction: Sendable, CustomTestStringConvertible {
    let name: String
    let configuration: ConnectorConfiguration
    let size: Vector3D

    var testDescription: String { name }
}

let targetConstructions = [
    TargetConstruction(name: "Reducing sleeve", configuration: reducingSleeve, size: [22, 22, 22]),
    TargetConstruction(name: "Extension of two stocks", configuration: extensionOfTwoStocks, size: [27, 51, 27]),
    TargetConstruction(name: "Tee joining three stocks", configuration: teeJoiningThreeStocks, size: [93, 60, 27]),
    TargetConstruction(name: "Tee joining a stock to a perpendicular stock", configuration: teeJoiningPerpendicularStock, size: [77, 52, 27]),
    TargetConstruction(name: "Corner with two stocks", configuration: cornerWithTwoStocks, size: [60, 60, 27]),
    TargetConstruction(name: "Boxed corner with two stocks", configuration: boxedCornerWithTwoStocks, size: [60, 60, 27]),
    TargetConstruction(name: "Corner with three stocks", configuration: cornerWithThreeStocks, size: [60, 60, 60]),
]

// MARK: - Other configurations

let sixWayCross = referenceConfiguration([.minX, .maxX, .minY, .maxY, .minZ, .maxZ])

/// Volume removed by one M3 countersunk hole through a 2.4 mm wall with 0.2 mm tolerance.
let screwHoleVolume = Double.pi / 12 * 1.5 * (6.2 * 6.2 + 6.2 * 3.2 + 3.2 * 3.2) + Double.pi / 4 * 3.2 * 3.2 * 0.9
/// Cross-section area of a socket wall: 27 × 27 outside, 22.2 × 22.2 inside.
let socketWallArea = 27.0 * 27 - 22.2 * 22.2

