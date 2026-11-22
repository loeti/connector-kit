# Design

## Context

See proposal.md for why. The layout already knows the hub size per axis (`hubLength(along:)`),
which is where the stock stops; the stop lip and pass-through are handled there too. The customizer
model is a single `Model("Connector")` whose geometry is built from parameters in
`ParametricConnector`. Cadova lets a model's `Metadata` depend on parameters and updates the page
with every build.

## Goals / Non-Goals

**Goals:**
- One place that computes the stop distance and the outer offset, used by the customizer and by
  tests, so the numbers shown to the user are the numbers the geometry has.

**Non-Goals:**
- No cut-list calculator for whole frames in the customizer; the user does the subtraction.
- No change to the connector geometry.

## Decisions

### Distances come from the layout, not from separate formulas
`ConnectorLayout` gets `stopDistance(for:)` (nil for a pass-through arm) and
`outerOffset(for:)` (nil if the opposite direction has an arm), both derived from
`hubLength(along:)`. A `cutDeduction` helper applies the cutting tolerance (1): deductions below
it count as zero, which covers the stop lip; the geometric distances stay exact. Alternative: compute them in the customizer from the parameters. Rejected,
because the stop lip, pass-through and minimum wall rules would be duplicated and could drift
from the geometry.

### Report in the model description
`main.swift` builds the configuration once and passes it to both `Metadata(description:)` and the
geometry, so description and model can't disagree. The description lists the distances per arm
group (identical arms are reported once) and the deduction for a frame measured over the
connectors. Alternative: encode the values in parameter labels or descriptions. Rejected, because
those are static texts.

This means the parameters move from `ParametricConnector.body` into a function that returns the
configuration, called from the model; `ParametricConnector` keeps only the geometry. Parameter
declarations keep their identity because they stay declared once.

### Tests check the distances against the geometry
Besides checking the numbers from the spec, a test inserts stock of the computed length between
two connectors positioned at a frame dimension apart and checks that it touches both stops without
overlapping (zero-volume intersection) — so the formula is proven against the real geometry.

## Risks / Trade-offs

- [Moving parameter declarations changes their keys] → The customizer identifies parameters by
  where they're declared, so values a visitor has set may reset once. Acceptable while the
  customizer is new.
- [Distances per arm can differ, e.g. a pass-through tee] → The description groups arms by
  distance and names the pass-through axis instead of a stop distance.
