import Testing
@testable import ConnectorKit

struct CutLengthReportTests {
    func report(_ configuration: ConnectorConfiguration) -> String {
        CutLengthReport(layout: ConnectorLayout(configuration: configuration, clearance: 0.2)).text
    }

    @Test func `Default corner reports 13.5, 27 and 54`() {
        #expect(report(cornerWithThreeStocks) == """
            Cut lengths, with frame dimensions measured over the connectors:
            Arms +X, +Y, +Z: the stock ends 13.5 mm from the connector's center and 27 mm from its outer face.
            Between two of these connectors, cut each stock 54 mm shorter than the frame dimension.
            """)
    }

    @Test func `Extension is cut to the total length`() {
        #expect(report(extensionOfTwoStocks) == """
            Cut lengths, with frame dimensions measured over the connectors:
            Arms −Y, +Y: the stocks meet at a stop lip within the cutting tolerance, so together they are cut to the total length.
            """)
    }

    @Test func `Pass-through names the axis that runs through`() {
        #expect(report(teeJoiningPerpendicularStock) == """
            Cut lengths, with frame dimensions measured over the connectors:
            The stock along X runs through without a stop.
            Arm −Y: the stock ends 13.5 mm from the connector's center and 27 mm from its outer face.
            """)
        #expect(report(reducingSleeve).contains("The stock along X runs through without a stop."))
    }

    @Test func `Arms with different deductions are reported separately`() {
        #expect(report(teeJoiningThreeStocks) == """
            Cut lengths, with frame dimensions measured over the connectors:
            Arms −X, +X: the stock ends 13.5 mm from the connector's center.
            Arm +Y: the stock ends 13.5 mm from the connector's center and 27 mm from its outer face.
            """)
    }

    @Test func `Lengths are shown with at most one decimal`() {
        #expect(CutLengthReport.format(27) == "27")
        #expect(CutLengthReport.format(13.5) == "13.5")
        #expect(CutLengthReport.format(13.8000001) == "13.8")
    }
}
