import Cadova

/// Connector for stock: hub, sockets and gussets, built from a ``ConnectorConfiguration``.
/// The hub is centered at the origin.
public struct Connector: Geometry3D {
    public let configuration: ConnectorConfiguration

    public init(_ configuration: ConnectorConfiguration) {
        self.configuration = configuration
    }

    public var body: any Geometry3D {
        @Environment(\.tolerance) var tolerance
        let layout = ConnectorLayout(configuration: configuration, clearance: tolerance)

        Union {
            if let hub = layout.hub {
                hub
            }
            for socket in layout.sockets {
                socket.outline
            }
            for gusset in layout.gussets {
                gusset
            }
            for wall in layout.gussetEdgeWalls {
                wall
            }
        }
        .subtracting {
            // Cavities, openings and screw holes come after the union, so nothing protrudes into them
            for socket in layout.sockets {
                socket.negativeBody
            }
            for opening in layout.hubOpenings {
                opening
            }
            for channel in layout.stockChannels {
                channel
            }
        }
    }
}

/// The stock inserted into a connector, for use as background reference geometry.
public struct InsertedStock: Geometry3D {
    public let configuration: ConnectorConfiguration
    public let length: Double

    public init(_ configuration: ConnectorConfiguration, length: Double) {
        self.configuration = configuration
        self.length = length
    }

    public var body: any Geometry3D {
        @Environment(\.tolerance) var tolerance
        let layout = ConnectorLayout(configuration: configuration, clearance: tolerance)

        for piece in layout.stockPieces(length: length) {
            piece
        }
    }
}
