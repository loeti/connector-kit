import Testing
import Cadova
@testable import ConnectorKit

/// openspec/specs/target-constructions
struct TargetConstructionTests {
    let environment: @Sendable (inout EnvironmentValues) -> Void = { $0.tolerance = 0.2 }

    @Test(arguments: targetConstructions)
    func `Is one printable piece that takes its stock`(_ construction: TargetConstruction) async throws {
        let configuration = construction.configuration
        let (pieces, overlap) = try await ModelFileGenerator.evaluate(environment: environment) { evaluator in
            let connector = Connector(configuration)
            let pieces = await evaluator.components(of: connector).count
            let overlap = await evaluator.measurements(
                of: connector.intersecting { InsertedStock(configuration, length: 60) }
            ).volume
            return (pieces, overlap)
        }
        #expect(pieces == 1)
        #expect(overlap < 0.001, "Overlap \(overlap) mm³")
    }

    @Test(arguments: targetConstructions)
    func `Has the size its spec requires`(_ construction: TargetConstruction) async throws {
        let configuration = construction.configuration
        let size = try await ModelFileGenerator.evaluate(environment: environment) { evaluator in
            await evaluator.bounds(of: Connector(configuration))?.size
        }
        let actual = try #require(size)
        #expect(
            abs(actual.x - construction.size.x) < 0.01
                && abs(actual.y - construction.size.y) < 0.01
                && abs(actual.z - construction.size.z) < 0.01,
            "Size \(actual), expected \(construction.size)"
        )
    }

    // MARK: - Screws named in the spec

    func screwSides(_ configuration: ConnectorConfiguration, _ direction: DirectionalAxis<D3>) -> [DirectionalAxis<D3>] {
        ConnectorLayout(configuration: configuration, clearance: 0.2)
            .screwPlacements(for: Arm(direction))
            .map(\.side)
    }

    @Test func `Reducing sleeve has one screw on top`() {
        let layout = ConnectorLayout(configuration: reducingSleeve, clearance: 0.2)
        #expect(layout.passThroughHubSocket?.screwPlacements.map(\.side) == [.maxZ])
    }

    @Test func `Extension has two screws on top and two at the bottom`() {
        #expect(screwSides(extensionOfTwoStocks, .minY) == [.maxZ, .minZ])
        #expect(screwSides(extensionOfTwoStocks, .maxY) == [.maxZ, .minZ])
    }

    @Test func `Tees and flat corners have one screw on top of each arm`() {
        let flat: [(ConnectorConfiguration, [DirectionalAxis<D3>])] = [
            (teeJoiningThreeStocks, [.minX, .maxX, .maxY]),
            (teeJoiningPerpendicularStock, [.minX, .maxX, .minY]),
            (cornerWithTwoStocks, [.maxX, .maxY]),
            (boxedCornerWithTwoStocks, [.maxX, .maxY]),
        ]
        for (configuration, directions) in flat {
            for direction in directions {
                #expect(screwSides(configuration, direction) == [.maxZ], "Arm \(direction)")
            }
        }
    }

    @Test func `Three-way corner has screws on top and the vertical arm's screw on +Y`() {
        #expect(screwSides(cornerWithThreeStocks, .maxX) == [.maxZ])
        #expect(screwSides(cornerWithThreeStocks, .maxY) == [.maxZ])
        #expect(screwSides(cornerWithThreeStocks, .maxZ) == [.maxY])
    }

    @Test func `Tee joining three stocks has two gussets flush with the bottom`() {
        let gussets = ConnectorLayout(configuration: teeJoiningThreeStocks, clearance: 0.2).gussets
        #expect(gussets.count == 2)
        #expect(gussets.allSatisfy { $0.normal == .z && $0.apex.z == -13.5 })
    }
}
