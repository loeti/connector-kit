import Testing
import Cadova
@testable import ConnectorKit

/// openspec/specs/connector-layout: Valid pass-through axes
struct PassThroughTests {
    func layout(_ directions: [DirectionalAxis<D3>], passThrough axis: Axis3D) -> ConnectorLayout {
        ConnectorLayout(configuration: referenceConfiguration(directions, passThroughAxis: axis), clearance: 0.2)
    }

    @Test func `Pass-through applies with arms in both directions or without arms`() {
        #expect(layout([.minX, .maxX, .minY], passThrough: .x).passThroughAxis == .x)
        #expect(ConnectorLayout(configuration: reducingSleeve, clearance: 0.2).passThroughAxis == .x)
        #expect(layout([.minX, .maxX, .minY], passThrough: .x).ignoredPassThroughAxis == nil)
    }

    @Test(arguments: [
        ([DirectionalAxis<D3>.maxZ], Axis3D.x),
        ([.maxZ], .y),
        ([.minZ, .maxZ], .x),
        ([.maxX, .maxZ], .y),
        ([.maxX, .maxY], .x),
    ])
    func `Pass-through is ignored elsewhere`(_ directions: [DirectionalAxis<D3>], _ axis: Axis3D) {
        let layout = layout(directions, passThrough: axis)
        #expect(layout.passThroughAxis == nil)
        #expect(layout.ignoredPassThroughAxis == axis)
    }

    @Test func `An ignored pass-through builds the same connector as none`() async throws {
        let ignored = referenceConfiguration([.maxZ], passThroughAxis: .x)
        let none = referenceConfiguration([.maxZ])
        let (a, b) = try await ModelFileGenerator.evaluate(environment: { $0.tolerance = 0.2 }) { evaluator in
            (await evaluator.measurements(of: Connector(ignored)).volume,
             await evaluator.measurements(of: Connector(none)).volume)
        }
        #expect(abs(a - b) < 0.01, "Ignored \(a), none \(b)")
    }
}
