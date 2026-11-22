# Design

## Context

See proposal.md for why. Gussets are built in `ConnectorLayout.gussetPlacements` and drawn by
`Gusset`: a cylinder of the gusset radius around the apex, intersected with the quadrant box that
reaches the full radius along both arms. Centered gussets, the both-sides mode, `GussetEdgeWall`
and the stock channels that kept the stock free from gussets beyond the sockets all hang off that.

## Goals / Non-Goals

**Goals:**
- Gussets that never reach beyond a socket and never split the space between arms.
- Less code: remove what only existed for centered and two-sided gussets.

**Non-Goals:**
- Other gusset shapes (fillets, ribs) or a thickness different from the wall.

## Decisions

### Clip with the quadrant box, not with extra cutters
`Gusset` gets a `reach` (distance from the apex to the socket end, hub size + socket depth) next to
its `radius`, and the quadrant box spans `reach` instead of `radius` along both arms. The
cylinder still has the full radius, so the arc bulges between the arms and the box cuts it off
square at the socket ends. Alternative: subtract a box in front of each socket. Rejected, because
it needs to know about neighbouring arms and leaves the same tabs where two gussets overlap.

### Drop the stock channels
Stock channels were cut only because gussets reached beyond the sockets. With gussets ending at
the socket ends nothing can block the stock there, so `stockChannels` goes, and the fit tests
prove that nothing blocks it.

### Keep the parameter name "Gusset overhang"
The parameter keeps its label and declaration, so existing values stay; only its description
changes to say that it sets how far the arc bulges between the arms. Alternative: rename it to
"Gusset radius". Rejected for now: the value is still measured beyond the socket ends, which is
easier to choose than an absolute radius.

## Risks / Trade-offs

- [Smaller connectors, less stiffness at the arm ends] → The gusset still covers the corner
  between the arms up to the socket ends; the original 8 mm ledge under the stock carried no load.
- [Overhang 0 makes the arc touch the socket ends only at the back edge] → The gusset then is a
  plain quarter disc of radius 52; acceptable, the parameter range starts at 0 on purpose.
