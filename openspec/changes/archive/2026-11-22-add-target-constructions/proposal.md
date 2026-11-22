# Proposal

## Why

The specs describe the rules (wall sizing, screws, gussets, …) but not which constructions those
rules have to produce. Without a stated target, it isn't clear when the kit is complete or whether
a change to a rule breaks a shape someone relies on. The target constructions also guide the
roadmap: shapes that can't be made yet show up as gaps.

Someone building a frame also needs to know how long to cut the stock. For a box of
1000 × 600 × 500 mm made from 22 mm battens, the cut lengths must follow from the box dimensions
with one simple, stated deduction per connector, and the customizer has to show that deduction
because it changes with the stock, the wall and the kind of stop.

## What Changes

- New capability listing the target constructions: reducing sleeve (adapter), extension of two
  stocks, tee joining three stocks, tee joining a stock to a perpendicular second stock (the first
  runs through), corner with two stocks (elbow), boxed elbow, and corner with three stocks.
- Each construction is stated as the parameter values that produce it and the dimensions and
  features it must have, using the default socket (22 mm stock, 27 mm outer size, 25 mm socket
  depth, 0.2 clearance, M3 screws, 8 mm gusset overhang) unless a construction says otherwise.
- Constructions stay combinations of parameters: they don't become presets in the library or a
  selection in the customizer (consistent with the customizer spec).
- New capability for cut lengths: every connector has a stop distance (from its center to the
  stock end) and an outer offset (from its outer face to the stock end), and stock lengths follow
  from frame dimensions by subtracting them.
- The customizer reports these distances and the resulting deduction for the current parameters.
- Frame dimensions are measured over the outside of the connectors; stock lengths follow from
  them. Deductions within the cutting tolerance of wood count as zero, so an extension adds no
  length.
- Roof constructions (ridge joint for a gable roof) come later and are out of scope.

## Capabilities

### New Capabilities
- `target-constructions`: the constructions the connector kit must be able to produce, each with
  the parameters that produce it and checkable dimensions.
- `cut-lengths`: how far the stock ends from a connector's center and outer face, and how stock
  cut lengths follow from frame dimensions.

### Modified Capabilities
- `customizer`: the model description reports the stop distance, the outer offset and the
  deduction per stock for the current parameters.

## Impact

- New spec `openspec/specs/target-constructions/spec.md`.
- Tests: one check per construction (bounding box, single piece, stock fit, screw holes), reusing
  the existing test configurations where they match.
- README: the shapes table points to the spec instead of listing shapes on its own.
- Library: the layout exposes the stop distance and the outer offset; no change to the geometry.
- Customizer: the model description is computed from the parameters.
