import Cadova
import ConnectorKit

await Project {
    Metadata(
        title: "Connector Kit",
        description: "Parametric, printable parts built from reusable sizing rules."
    )

    await Model("Connector") {
        let parameters = ConnectorParameters.read()

        let layout = ConnectorLayout(configuration: parameters.configuration, clearance: parameters.clearance)

        Metadata(
            title: "Connector",
            description: """
                Joins square stock with sockets along any of the six axis directions. Each socket wall follows the sizing rule, never going below the minimum thickness.

                \(CutLengthReport(layout: layout).text)
                """
        )
        ParametricConnector(parameters: parameters)
    }
}
