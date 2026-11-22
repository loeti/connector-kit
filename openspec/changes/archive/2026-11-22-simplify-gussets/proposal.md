# Proposal

## Why

With more than two arms the gussets produce artifacts: where a third axis has arms in both
directions, a centered gusset splits the space between the arms, and the stock channel cut through
it leaves thin slivers and pins standing. Beyond the socket ends, the gussets' 8 mm overhang runs
under the stock, and where gussets meet an arm from both sides their arcs overlap into irregular
tabs. The "both sides" mode with its edge walls adds complexity that isn't needed.

## What Changes

- **BREAKING** No centered gussets: a pair of perpendicular arms gets no gusset when the axis
  perpendicular to both has arms in both directions.
- **BREAKING** The "both sides" mode and its edge walls are removed; gussets are always placed
  automatically. The customizer parameter "Gusset sides" goes away.
- **BREAKING** Every gusset ends flush with the socket ends; it never reaches beyond a socket.
  The overhang only sets how far the arc bulges into the corner between the arms. As a result the
  connectors get smaller: the three-way corner is 52 × 52 × 52 instead of 60 × 60 × 60.
- Screws no longer need to avoid faces split by centered gussets, because there are none.
- The target construction "Boxed corner with two stocks" is removed; the sizes of the other
  constructions follow the clipped gussets. Cut lengths don't change.

## Capabilities

### New Capabilities

None.

### Modified Capabilities
- `gussets`: clipped at the socket ends, no centered gussets, no gussets on both faces; the
  requirement that kept the stock free beyond the sockets becomes a guarantee that gussets end at
  the sockets.
- `screws`: the face rule no longer mentions centered gussets.
- `target-constructions`: boxed corner removed; sizes of the tee joining three stocks, the corners
  with two and three stocks updated.
- `customizer`: "Gusset sides" parameter removed.

## Impact

- Library: `GussetStyle` loses its sides, `GussetSides` and `GussetEdgeWall` are removed, the layout
  no longer places centered gussets, edge walls or stock channels, `Gusset` is clipped at the
  socket ends.
- Customizer: one parameter less; values visitors set for "Gusset sides" disappear.
- Tests and README: boxed corner removed, sizes and volumes updated.
