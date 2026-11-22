# Design

## Context

See proposal.md for why. `ConnectorConfiguration.passThroughAxis` is read directly in
`ConnectorLayout` (`hubLength`, `hubOpenings`, `stopDistance`, `outerOffset`, `stockPieces`,
`passThroughHubSocket`) and in `CutLengthReport`.

## Goals / Non-Goals

**Goals:**
- One place decides whether the configured pass-through is used.
- The configuration keeps what the user chose, so the description can explain an ignored choice.

**Non-Goals:**
- Changing the customizer's pass-through parameter itself; Cadova's choice parameters have a fixed
  list of cases.

## Decisions

### Effective pass-through axis in the layout
`ConnectorLayout` gets `passThroughAxis: Axis3D?`, the configured axis if it is valid, otherwise
`nil`, and all layout code uses it instead of `configuration.passThroughAxis`. A second property,
`ignoredPassThroughAxis`, returns the configured axis when it was ignored. Alternative: reject an
invalid axis in `ConnectorConfiguration.init` with a precondition. Rejected, because the customizer
would crash on a choice the user can make.

### Hub screws follow from validity
`passThroughHubSocket` keeps its shape but only applies when there are no arms; with a valid
pass-through and arms, both directions have arms by definition, so the old "no arm on that axis"
branch can't occur anymore and is removed.

### Description line
`CutLengthReport` adds "Pass-through along X is ignored: it needs arms in both directions along X,
or no arms at all." before the cut lengths when `ignoredPassThroughAxis` is set.

## Risks / Trade-offs

- [Links or saved values with an invalid pass-through change shape] → They now build without
  pass-through and the description says so.
