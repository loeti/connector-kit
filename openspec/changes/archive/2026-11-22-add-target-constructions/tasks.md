# Tasks

## 1. Stop distance and outer offset

- [x] 1.1 Add `stopDistance(for:)` and `outerOffset(for:)` to `ConnectorLayout`, derived from `hubLength(along:)`; verify with rule tests for the spec scenarios (13.5 / 27 for a 27 hub, 0 for the stop lip after the cutting tolerance, none for pass-through and for an arm with an opposite arm, 13.8 / 27.6 when the minimum wall applies, unchanged when only the clearance changes).
- [x] 1.2 Add a geometry test that places two three-way corners 1000 apart (outer faces) and checks that stock cut to 1000 − 2 × 27 touches both stops without overlapping either connector; verify it fails with a cut length of 1000 − 2 × 26.

## 2. Target constructions

- [x] 2.1 Define one test configuration per target construction in `Tests/ConnectorKitTests/TestConfigurations.swift` (reusing `reducingSleeve`, `straightCoupler`, `passThroughTee`, `flatElbow`, `boxedElbow`, `threeWayCorner`, and adding the tee joining three stocks), named after the construction; verify the test target builds.
- [x] 2.2 Add a parameterized test over all target constructions that checks each is one piece and that its inserted stock doesn't overlap it; verify it passes for all seven.
- [x] 2.3 Add a test per construction for the bounding box from the spec (22³, 27 × 51 × 27, 93 × 60 × 27, 77 × 52 × 27, 60 × 60 × 27 twice, 60³); verify each passes.
- [x] 2.4 Check the screw holes the spec names per construction (count and faces) through the layout's screw placements; verify the tests pass.
- [x] 2.5 Render the tee joining three stocks, the only construction not rendered before, and check its gussets, hub and screws visually.

## 3. Customizer description

- [x] 3.1 Move the parameter declarations out of `ParametricConnector.body` into a function that returns the configuration and clearance; build the model from it in `main.swift` and verify `swift run` still writes the default corner (60 × 60 × 60, same volume as before).
- [x] 3.2 Compose the model description from the layout (stop distance, outer offset, deduction per stock, pass-through axis) and pass it to `Metadata`; verify with a test of the description text for the default corner, the extension and a pass-through configuration.
- [x] 3.3 Build the customizer locally (Docker) and verify the description updates when arms, outer size or pass-through change.

## 4. Documentation

- [x] 4.1 Replace the shapes table in `README.md` with the target constructions and a "Cut lengths" section with the box example (1000 × 600 × 500 → 946, 546, 446); verify the links resolve.
- [x] 4.2 Run `openspec validate --all --strict` and verify it passes.

## Workflow follow-up

- Archive the change once the tests pass, which moves the new specs to `openspec/specs/` and merges the customizer requirement.
