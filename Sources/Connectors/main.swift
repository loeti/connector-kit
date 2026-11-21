import Cadova

await Project {
    Metadata(
        title: "Connector Kit",
        description: "Parametric, printable parts built from reusable sizing rules."
    )

    await Model("Connector") {
        Metadata(
            title: "Connector",
            description: "Joins square stock with sockets along any of the six axis directions. Each socket wall follows the sizing rule, never going below the minimum thickness."
        )
        ParametricConnector()
    }
}
