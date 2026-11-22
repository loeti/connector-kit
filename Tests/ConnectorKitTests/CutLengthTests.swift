import Testing
import Cadova
@testable import ConnectorKit

struct CutLengthTests {
    func layout(_ configuration: ConnectorConfiguration, clearance: Double = 0.2) -> ConnectorLayout {
        ConnectorLayout(configuration: configuration, clearance: clearance)
    }

    @Test func `Stock stops half a hub from the center and a whole hub from the outer face`() {
        let corner = layout(cornerWithThreeStocks)
        for direction in [DirectionalAxis<D3>.maxX, .maxY, .maxZ] {
            #expect(corner.stopDistance(for: Arm(direction)) == 13.5)
            #expect(corner.outerOffset(for: Arm(direction)) == 27)
        }
    }

    @Test func `A box of 1000 × 600 × 500 needs stock of 946, 546 and 446`() throws {
        let corner = layout(cornerWithThreeStocks)
        let deduction = try #require(corner.cutDeduction(for: Arm(.maxX), measuredTo: .outerFace))
        #expect([1000.0, 600, 500].map { $0 - 2 * deduction } == [946, 546, 446])
    }

    @Test func `A tee within a side is measured to its center`() throws {
        let corner = try #require(layout(cornerWithThreeStocks).cutDeduction(for: Arm(.maxX), measuredTo: .outerFace))
        let tee = try #require(layout(teeJoiningThreeStocks).cutDeduction(for: Arm(.maxX), measuredTo: .center))
        #expect(500 - corner - tee == 459.5)
    }

    @Test func `The stop lip of an extension is within the cutting tolerance`() throws {
        let coupler = layout(extensionOfTwoStocks)
        #expect(coupler.stopDistance(for: Arm(.maxY)) == 0.5)
        #expect(coupler.cutDeduction(for: Arm(.maxY), measuredTo: .center) == 0)
        // Opposite arms: there is no outer face to measure over
        #expect(coupler.outerOffset(for: Arm(.maxY)) == nil)
    }

    @Test func `Stock that passes through has no stop`() {
        let tee = layout(teeJoiningPerpendicularStock)
        #expect(tee.stopDistance(for: Arm(.maxX)) == nil)
        #expect(tee.stopDistance(for: Arm(.minY)) == 13.5)
        #expect(tee.outerOffset(for: Arm(.minY)) == 27)
    }

    @Test func `Clearance doesn't change the deductions`() {
        let corner = layout(cornerWithThreeStocks, clearance: 0.4)
        #expect(corner.stopDistance(for: Arm(.maxX)) == 13.5)
        #expect(corner.outerOffset(for: Arm(.maxX)) == 27)
    }

    @Test func `Deductions follow the hub when the minimum wall applies`() throws {
        var configuration = cornerWithThreeStocks
        configuration.socket = SocketSpec(stock: Stock(size: 25), wallRule: WallRule(.outerSize(27)))
        let corner = layout(configuration)
        let stop = try #require(corner.stopDistance(for: Arm(.maxX)))
        let offset = try #require(corner.outerOffset(for: Arm(.maxX)))
        #expect(abs(stop - 13.8) < 1e-9)
        #expect(abs(offset - 27.6) < 1e-9)
    }

    /// Two corners whose outer faces are `frame` apart along X, and stock of `length` between them.
    func overlapOfStock(length: Double, frame: Double) async throws -> Double {
        let hub = 27.0
        let left = cornerWithThreeStocks
        let right = referenceConfiguration([.minX, .maxY, .maxZ])
        return try await ModelFileGenerator.evaluate(environment: { $0.tolerance = 0.2 }) { evaluator in
            let corners = Union {
                Connector(left)
                Connector(right).translated(x: frame - hub)
            }
            let stock = Box(x: length, y: 22, z: 22)
                .aligned(at: .centerY, .centerZ)
                .translated(x: hub / 2)
            return await evaluator.measurements(of: corners.intersecting { stock }).volume
        }
    }

    @Test func `Stock cut by the rule fits exactly between two corners`() async throws {
        let frame = 1000.0
        let deduction = try #require(layout(cornerWithThreeStocks).cutDeduction(for: Arm(.maxX), measuredTo: .outerFace))
        // Cut by the rule: touches both stops without overlapping
        #expect(try await overlapOfStock(length: frame - 2 * deduction, frame: frame) < 0.001)
        // One millimetre too long at each end: runs into the hub
        #expect(try await overlapOfStock(length: frame - 2 * (deduction - 1), frame: frame) > 900)
    }
}
