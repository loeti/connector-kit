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

    @Test func `No gusset where the third axis has arms in both directions`() {
        // ±X, ±Y and +Z: only the four pairs in the XY plane, flush with the bottom
        let five = ConnectorLayout(configuration: fiveWay, clearance: 0.2).gussets
        #expect(five.count == 4)
        #expect(five.allSatisfy { $0.normal == .z && $0.apex.z == -13.5 })
        #expect(ConnectorLayout(configuration: sixWayCross, clearance: 0.2).gussets.isEmpty)
    }

    @Test func `Gussets end at the socket ends`() {
        let gussets = ConnectorLayout(configuration: cornerWithThreeStocks, clearance: 0.2).gussets
        #expect(gussets.count == 3)
        #expect(gussets.allSatisfy { $0.reach == 52 && $0.radius == 60 })
    }

    @Test func `Every face along the arm can take a screw`() {
        let layout = ConnectorLayout(configuration: sixWayCross, clearance: 0.2)
        #expect(layout.automaticScrewSide(for: Arm(.maxX)) == .maxZ)
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

    @Test func `Only a reducing sleeve gets screws in the hub`() {
        let sleeve = ConnectorLayout(configuration: reducingSleeve, clearance: 0.2)
        #expect(sleeve.passThroughHubSocket?.screwPlacements.map(\.side) == [.maxZ])

        // A through tee is held by the screws of its arms along X
        let tee = ConnectorLayout(configuration: teeJoiningPerpendicularStock, clearance: 0.2)
        #expect(tee.passThroughHubSocket == nil)
        #expect(tee.screwPlacements(for: Arm(.maxX)).map(\.side) == [.maxZ])
    }
}
