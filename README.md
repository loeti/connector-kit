# Connector Kit

Parametric, 3D-printable connectors for square stock, such as wooden battens, built with
[Cadova](https://github.com/tomasf/Cadova). Every dimension follows from a few reusable sizing
rules, so the same code makes a corner for 22 mm battens or a tee for 30 mm tubes.

![A three-way corner, an extension, a tee joining a stock to a perpendicular stock, and a tee joining three stocks](Images/connectors.png)

**[Open the customizer](https://loeti.github.io/connector-kit/)** to set the parameters, preview
the connector in 3D and download a 3MF file for your slicer. It runs entirely in your browser.

## Connectors

A connector has a socket (arm) along any of the six axis directions. Turning arms on and off,
and choosing whether the stock passes through, gives the
[target constructions](openspec/specs/target-constructions/spec.md):

| Construction | Arms | Other parameters | Size |
|---|---|---|---|
| Reducing sleeve (adapter) | none | pass-through X, stock 13, outer size 22 | 22 × 22 × 22 |
| Extension of two stocks | −Y, +Y | 2 screws per arm | 27 × 51 × 27 |
| Tee joining three stocks | −X, +X, +Y | | 77 × 52 × 27 |
| Tee joining a stock to a perpendicular stock | −X, +X, −Y | pass-through X, no gussets | 77 × 52 × 27 |
| Corner with two stocks | +X, +Y | | 52 × 52 × 27 |
| Corner with three stocks | +X, +Y, +Z | | 52 × 52 × 52 |

Sizes are for 22 mm stock with the default parameters. Roof constructions follow later.

## Cut lengths

Plan a frame by its outer size, measured over the connectors. Each stock is then cut shorter by
how far the stock ends from the connector's outer face: the hub size, 27 mm by default.

For a box of 1000 × 600 × 500 mm with three-way corners, every stock loses 2 × 27 = 54 mm:

| Edges | Count | Cut length |
|---|---|---|
| 1000 | 4 | 946 mm |
| 600 | 4 | 546 mm |
| 500 | 4 | 446 mm |

Where a dimension is measured to the center of a connector, such as a tee within a side, subtract
half the hub (13.5 mm) at that end instead. An extension adds no length: its 1 mm stop lip is
within the cutting tolerance, so two stocks of 1000 mm make 2000 mm. The customizer shows these
values for the current parameters, and the rules are specified in
[cut-lengths](openspec/specs/cut-lengths/spec.md).

## Parameters

| Parameter | Default | Description |
|---|---|---|
| Stock size | 22 mm | Width of the square stock |
| Clearance | 0.2 mm | Total play between stock and socket (both sides combined); also added to the screw holes |
| Socket depth | 25 mm | How far the stock goes into each socket |
| Wall sizing | Outer size | Size the sockets by their outer size or by their wall thickness |
| Outer size / Wall thickness | 27 mm / 2.4 mm | The value for the chosen wall sizing |
| Minimum wall thickness | 1.2 mm | The wall is never thinner than this |
| Arm towards ±X/±Y/±Z | +X, +Y, +Z | Which arms the connector has |
| Pass-through | None | Axis along which the stock runs straight through; only applies with arms in both directions along it, or without any arms (reducing sleeve) |
| Gussets | On | Quarter-disc plates between perpendicular arms |
| Gusset overhang | 8 mm | How far the gusset's arc bulges into the corner between the arms; gussets end at the socket ends |
| Screws | M3 | Countersunk screw (M2–M6) or none |
| Screws per arm | 1 | One or two screws per socket |
| Show stock | Off | Shows the inserted stock as reference; it isn't printed |

## Sizing rules

Every dimension follows from a few rules, for example: the wall is
`(outer size − stock − clearance) / 2` but never thinner than the minimum, so 22 mm stock in a
27 mm socket gets a 2.4 mm wall (2.4 + 0.1 + 22 + 0.1 + 2.4 = 27).

The rules are specified with [OpenSpec](https://github.com/Fission-AI/OpenSpec) in
[`openspec/specs`](openspec/specs), each with its reason and concrete scenarios:

| Spec | Covers |
|---|---|
| [socket-sizing](openspec/specs/socket-sizing/spec.md) | Stock, clearance, wall thickness and its minimum |
| [screws](openspec/specs/screws/spec.md) | Hole sizes, countersinks, which faces get screws, screws in the hub |
| [connector-layout](openspec/specs/connector-layout/spec.md) | Arms, hub, stop lip, pass-through |
| [gussets](openspec/specs/gussets/spec.md) | Quarter-disc gussets between the arms and where they sit |
| [customizer](openspec/specs/customizer/spec.md) | The parametric model, its parameters and publishing |
| [target-constructions](openspec/specs/target-constructions/spec.md) | The constructions the kit must produce |
| [cut-lengths](openspec/specs/cut-lengths/spec.md) | Where the stock ends and how to work out cut lengths |

Changes to the rules start as an OpenSpec change proposal in `openspec/changes`.

## Using the library

Add the package to your own Cadova project:

```swift
.package(url: "https://github.com/loeti/connector-kit.git", branch: "main")
```

and build a connector from a configuration:

```swift
import Cadova
import ConnectorKit

let corner = ConnectorConfiguration(
    socket: SocketSpec(stock: Stock(size: 22), wallRule: WallRule(.outerSize(27))),
    socketDepth: 25,
    arms: [Arm(.maxX), Arm(.maxY), Arm(.maxZ)],
    screw: .countersunk(.m3),
    gussets: .quarterDisc(overhang: 8)
)

await Model("Corner") {
    Connector(corner)
        .withTolerance(0.2)
}
```

The building blocks (`Hub`, `Socket`, `ScrewHole`, `Gusset`) are public as
well, for parts that aren't connectors.

## Building

Requires Swift 6.3 and macOS 15 or later.

```sh
swift run Connectors    # writes Models/Connector.3mf with the default parameters
swift test              # checks the sizing rules, dimensions, volumes and fit
```

Open the 3MF file in [Cadova Viewer](https://github.com/tomasf/CadovaViewer), which reloads it
whenever it's rebuilt, or in any slicer.

The customizer is published on GitHub Pages by the `Customizer` workflow on every push to
`main`. To build it locally, install the Swift 6.4.0 toolchain from swift.org
(`swiftly install 6.4.0`) and run:

```sh
swift package generate-customizer --product Connectors
python3 -m http.server --directory Customizer 8000
```

## License

[MIT](LICENSE)
