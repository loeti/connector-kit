import Testing
import Cadova
import Helical
@testable import ConnectorKit

struct RuleTests {
    let reference = SocketSpec(stock: Stock(size: 22), wallRule: WallRule(.outerSize(27)))

    @Test func `22 mm stock in a 27 mm socket gives a 2.4 mm wall`() {
        let dimensions = reference.dimensions(clearance: 0.2)
        #expect(abs(dimensions.wallThickness - 2.4) < 1e-9)
        #expect(abs(dimensions.innerWidth - 22.2) < 1e-9)
        #expect(abs(dimensions.outerWidth - 27) < 1e-9)
        #expect(dimensions.isWallAtMinimum == false)
    }

    @Test func `Stock that is too thick gets the minimum wall and a larger socket`() {
        let spec = SocketSpec(stock: Stock(size: 25), wallRule: WallRule(.outerSize(27)))
        let dimensions = spec.dimensions(clearance: 0.2)
        // (27 − 25 − 0.2) / 2 = 0.9 < 1.2
        #expect(dimensions.wallThickness == 1.2)
        #expect(dimensions.isWallAtMinimum)
        #expect(abs(dimensions.outerWidth - 27.6) < 1e-9)
    }

    @Test func `A fixed wall thickness determines the outer size`() {
        let spec = SocketSpec(stock: Stock(size: 30), wallRule: WallRule(.thickness(2)))
        let dimensions = spec.dimensions(clearance: 0.4)
        #expect(dimensions.wallThickness == 2)
        #expect(abs(dimensions.outerWidth - 34.4) < 1e-9)
    }

    @Test func `A fixed wall thickness doesn't go below the minimum either`() {
        let spec = SocketSpec(stock: Stock(size: 22), wallRule: WallRule(.thickness(0.8)))
        #expect(spec.dimensions(clearance: 0.2).wallThickness == 1.2)
    }

    @Test func `The head is countersunk only if the wall can take it`() {
        let screw = SocketScrew.countersunk(.m3)
        // 6 mm head on a 3 mm shank at 90°: 1.5 mm tall
        guard case .recessedHead = screw.entry(forWallThickness: 2.4) else {
            Issue.record("A 2.4 mm wall should take the countersunk head")
            return
        }
        guard case .plain = screw.entry(forWallThickness: 1.2) else {
            Issue.record("A 1.2 mm wall is too thin for the countersunk head")
            return
        }
    }

    @Test func `Screws go on top of horizontal arms and towards the back of vertical ones`() {
        let layout = ConnectorLayout(configuration: cornerWithThreeStocks, clearance: 0.2)
        #expect(layout.automaticScrewSide(for: Arm(.maxX)) == .maxZ)
        #expect(layout.automaticScrewSide(for: Arm(.maxY)) == .maxZ)
        #expect(layout.automaticScrewSide(for: Arm(.maxZ)) == .maxY)
    }

    @Test func `Screws avoid faces split by a centered gusset`() {
        // With arms on all six sides, every gusset is centered, so each face that has a
        // perpendicular arm next to it is blocked. A plus-shaped flat cross leaves the top free.
        let cross = referenceConfiguration([.minX, .maxX, .minY, .maxY])
        let layout = ConnectorLayout(configuration: cross, clearance: 0.2)
        #expect(layout.automaticScrewSide(for: Arm(.maxX)) == .maxZ)

        let sixWay = ConnectorLayout(configuration: sixWayCross, clearance: 0.2)
        #expect(sixWay.automaticScrewSide(for: Arm(.maxX)) == nil)
    }

    @Test func `Two screws per arm go on opposite faces, a third and two thirds along`() {
        let layout = ConnectorLayout(configuration: extensionOfTwoStocks, clearance: 0.2)
        let placements = layout.screwPlacements(for: Arm(.maxY))
        #expect(placements.map(\.side) == [.maxZ, .minZ])
        #expect(placements.map(\.position) == [1.0 / 3, 2.0 / 3])
    }

    @Test func `A straight connector has a stop lip instead of a hub, unless the stock passes through`() {
        let coupler = ConnectorLayout(configuration: extensionOfTwoStocks, clearance: 0.2)
        #expect(coupler.hubLength(along: .y) == 1)
        #expect(coupler.hubLength(along: .x) == 27)

        var sleeve = extensionOfTwoStocks
        sleeve.passThroughAxis = .y
        #expect(ConnectorLayout(configuration: sleeve, clearance: 0.2).hub == nil)
    }

    @Test func `Hub screws avoid faces that have an arm`() {
        // Stock passes through along X; the arm on +Z takes the preferred top face
        var configuration = reducingSleeve
        configuration.arms = [Arm(.maxZ)]
        let layout = ConnectorLayout(configuration: configuration, clearance: 0.2)
        #expect(layout.passThroughHubSocket?.screwPlacements.map(\.side) == [.maxY])

        // With an arm on the pass-through axis, that arm holds the stock instead
        configuration.arms = [Arm(.maxX)]
        #expect(ConnectorLayout(configuration: configuration, clearance: 0.2).passThroughHubSocket == nil)
    }
}
