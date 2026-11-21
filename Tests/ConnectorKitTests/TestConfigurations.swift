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

let threeWayCorner = referenceConfiguration([.maxX, .maxY, .maxZ])
let flatElbow = referenceConfiguration([.maxX, .maxY])
let flatTee = referenceConfiguration([.minX, .maxX, .maxY])
let sixWayCross = referenceConfiguration([.minX, .maxX, .minY, .maxY, .minZ, .maxZ])

/// Two arms on one axis with a stop lip in between, two screws per arm.
let straightCoupler = referenceConfiguration([.minY, .maxY], gussets: .none, screwsPerArm: 2)
/// Stock runs straight through along X, with a branch towards −Y.
let passThroughTee = referenceConfiguration([.minX, .maxX, .minY], gussets: .none, passThroughAxis: .x)
/// Flat elbow closed by gussets on both faces and walls along their edges.
let boxedElbow = referenceConfiguration([.maxX, .maxY], gussets: .quarterDisc(overhang: 8, sides: .both))

/// Volume removed by one M3 countersunk hole through a 2.4 mm wall with 0.2 mm tolerance.
let screwHoleVolume = Double.pi / 12 * 1.5 * (6.2 * 6.2 + 6.2 * 3.2 + 3.2 * 3.2) + Double.pi / 4 * 3.2 * 3.2 * 0.9
/// Cross-section area of a socket wall: 27 × 27 outside, 22.2 × 22.2 inside.
let socketWallArea = 27.0 * 27 - 22.2 * 22.2
