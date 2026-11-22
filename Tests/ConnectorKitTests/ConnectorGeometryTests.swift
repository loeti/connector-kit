import Foundation
import Testing
import Cadova
@testable import ConnectorKit

struct ConnectorGeometryTests {
    let environment: @Sendable (inout EnvironmentValues) -> Void = { $0.tolerance = 0.2 }

    @Test func `Three-way corner has the outer size of the reference design`() async throws {
        let bounds = try await ModelFileGenerator.evaluate(environment: environment) { evaluator in
            await evaluator.bounds(of: Connector(cornerWithThreeStocks))
        }
        let size = try #require(bounds?.size)
        // Hub 27 + socket 25 = 52; gussets end at the socket ends
        #expect(abs(size.x - 52) < 0.01)
        #expect(abs(size.y - 52) < 0.01)
        #expect(abs(size.z - 52) < 0.01)
    }

    @Test func `Three-way corner has the expected volume and is a single piece`() async throws {
        let (volume, componentCount) = try await ModelFileGenerator.evaluate(environment: environment) { evaluator in
            let connector = Connector(cornerWithThreeStocks)
            return (await evaluator.measurements(of: connector).volume, await evaluator.components(of: connector).count)
        }
        // Calculated by hand:
        let hub = 27.0 * 27 * 27                                    // 19683
        let sockets = 3 * (27.0 * 27 - 22.2 * 22.2) * 25            // 17712
        // A gusset is the 52 × 52 square within the radius 60 disc, minus the hub and sockets
        let gusset = (squareWithinDisc(side: 52, radius: 60) - (52 * 27 + 27 * 25)) * 2.4
        let expected = hub + sockets + 3 * gusset - 3 * screwHoleVolume
        #expect(abs(volume - expected) / expected < 0.005, "Volume \(volume), expected \(expected)")
        #expect(componentCount == 1)
    }

    @Test func `Screw holes remove material`() async throws {
        var withoutScrews = cornerWithThreeStocks
        withoutScrews.screw = nil
        let removed = try await ModelFileGenerator.evaluate(environment: environment) { [withoutScrews] evaluator in
            let full = await evaluator.measurements(of: Connector(withoutScrews)).volume
            let drilled = await evaluator.measurements(of: Connector(cornerWithThreeStocks)).volume
            return full - drilled
        }
        #expect(abs(removed - 3 * screwHoleVolume) < 5, "Removed \(removed), expected \(3 * screwHoleVolume)")
    }

    @Test(arguments: [cornerWithThreeStocks, cornerWithTwoStocks, teeJoiningThreeStocks, sixWayCross, fiveWay, extensionOfTwoStocks, teeJoiningPerpendicularStock])
    func `Stock fits without overlapping`(_ configuration: ConnectorConfiguration) async throws {
        // Stock touching the hub or a stop lip gives a degenerate, zero-volume intersection,
        // so this compares volume rather than asking whether the intersection is empty.
        let overlap = try await ModelFileGenerator.evaluate(environment: environment) { evaluator in
            await evaluator.measurements(
                of: Connector(configuration).intersecting { InsertedStock(configuration, length: 60) }
            ).volume
        }
        #expect(overlap < 0.001, "Overlap \(overlap) mm³")
    }

    @Test func `Stock butts against the hub`() async throws {
        // A slightly longer piece of stock, reaching into the hub, must intersect the hub
        let isEmpty = try await ModelFileGenerator.evaluate(environment: environment) { evaluator in
            await evaluator.isEmpty(
                Connector(cornerWithThreeStocks).intersecting {
                    Box(x: 30, y: 22, z: 22)
                        .aligned(at: .centerY, .centerZ)
                        .translated(x: 13.5 - 0.5)
                }
            )
        }
        #expect(isEmpty == false)
    }

    // MARK: - Reference designs from the STEP files

    func sizeAndVolume(of configuration: ConnectorConfiguration) async throws -> (Vector3D, Double) {
        try await ModelFileGenerator.evaluate(environment: environment) { evaluator in
            let connector = Connector(configuration)
            let size = await evaluator.bounds(of: connector)?.size ?? .zero
            return (size, await evaluator.measurements(of: connector).volume)
        }
    }

    @Test func `Straight coupler is a tube with a stop lip`() async throws {
        let (size, volume) = try await sizeAndVolume(of: extensionOfTwoStocks)
        // Two 25 mm sockets and the 1 mm lip
        #expect(abs(size.y - 51) < 0.01 && abs(size.x - 27) < 0.01 && abs(size.z - 27) < 0.01)
        let tube = socketWallArea * 51
        let lip = 1 * (22.2 * 22.2 - 21.2 * 21.2)
        let expected = tube + lip - 4 * screwHoleVolume
        #expect(abs(volume - expected) / expected < 0.005, "Volume \(volume), expected \(expected)")
    }

    @Test func `Pass-through tee lets the stock run through the hub`() async throws {
        let (size, volume) = try await sizeAndVolume(of: teeJoiningPerpendicularStock)
        #expect(abs(size.x - 77) < 0.01 && abs(size.y - 52) < 0.01 && abs(size.z - 27) < 0.01)
        let hub = 27.0 * 27 * 27 - 27 * 22.2 * 22.2
        let expected = hub + 3 * socketWallArea * 25 - 3 * screwHoleVolume
        #expect(abs(volume - expected) / expected < 0.005, "Volume \(volume), expected \(expected)")
    }


    @Test func `Reducing sleeve without arms holds the stock with a screw in the hub`() async throws {
        var withoutScrews = reducingSleeve
        withoutScrews.screw = nil
        let (size, full, drilled) = try await ModelFileGenerator.evaluate(environment: environment) { [withoutScrews] evaluator in
            let size = await evaluator.bounds(of: Connector(reducingSleeve))?.size ?? .zero
            let full = await evaluator.measurements(of: Connector(withoutScrews)).volume
            let drilled = await evaluator.measurements(of: Connector(reducingSleeve)).volume
            return (size, full, drilled)
        }
        #expect(abs(size.x - 22) < 0.01 && abs(size.y - 22) < 0.01 && abs(size.z - 22) < 0.01)

        // 22 cube with a 13.2 square hole along X
        #expect(abs(full - (22.0 * 22 * 22 - 22 * 13.2 * 13.2)) < 1, "Volume \(full)")
        // Wall (22 − 13.2) / 2 = 4.4: 1.5 mm countersink, then 2.9 mm of 3.2 mm hole
        let hole = Double.pi / 12 * 1.5 * (6.2 * 6.2 + 6.2 * 3.2 + 3.2 * 3.2) + Double.pi / 4 * 3.2 * 3.2 * 2.9
        #expect(abs(full - drilled - hole) < 3, "Removed \(full - drilled), expected \(hole)")
    }
}

/// Area of a square with one corner at the center of a disc, within that disc.
func squareWithinDisc(side a: Double, radius r: Double) -> Double {
    guard a * a * 2 > r * r else { return a * a }
    let x0 = (r * r - a * a).squareRoot()
    let integral = { (x: Double) in (x * (r * r - x * x).squareRoot() + r * r * asin(x / r)) / 2 }
    return a * x0 + integral(a) - integral(x0)
}
