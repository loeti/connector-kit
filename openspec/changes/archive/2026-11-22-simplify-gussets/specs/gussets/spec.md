## ADDED Requirements

### Requirement: Gussets end at the sockets
Gussets SHALL end at the socket ends, so the stock is free wherever it leaves a socket and no
stock channel needs to be cut through a gusset.

#### Scenario: Stock longer than the sockets
- **WHEN** stock longer than the sockets is inserted into any connector with gussets
- **THEN** the stock doesn't overlap any gusset

## MODIFIED Requirements

### Requirement: Quarter-disc gusset per pair of perpendicular arms
Each pair of perpendicular arms SHALL be braced by a quarter disc centered on the hub corner
opposite both arms, as thick as the socket wall, and clipped flush with the ends of both sockets,
so it never reaches beyond a socket and leaves no tabs. Its radius is the hub size plus the socket
depth plus the gusset overhang (default 8); the overhang only sets how far the arc bulges into the
corner between the arms.

#### Scenario: Reference corner
- **WHEN** 27 mm sockets with a depth of 25 and an overhang of 8 are used
- **THEN** the gusset radius is 27 + 25 + 8 = 60, each gusset ends at the socket ends 52 from its
  corner, and the three-way corner is 52 × 52 × 52

#### Scenario: Arc between the arms
- **WHEN** the same gusset is measured along its socket ends
- **THEN** it reaches √(60² − 52²) ≈ 29.9 from its corner there, 2.9 beyond the side of the socket

### Requirement: Automatic placement along the third axis
Each gusset SHALL sit flush with a hub face along the axis perpendicular to its two arms: on the −
side if that axis only has an arm in + direction (and vice versa), which gives a corner connector
flat back faces, and on the − side if that axis has no arm, which gives a flat bottom for printing.
If that axis has arms in both directions, the pair SHALL get no gusset, because a gusset in the
middle would split the space between the arms.

#### Scenario: Flat back faces
- **WHEN** a connector has arms +X, +Y and +Z
- **THEN** each of its three gussets is flush with the hub face on the − side of its third axis

#### Scenario: Arms in both directions
- **WHEN** a connector has arms −X, +X, −Y, +Y and +Z
- **THEN** only the four pairs in the XY plane get gussets, flush with the bottom, and the pairs
  with +Z get none

#### Scenario: Arms in all six directions
- **WHEN** a connector has arms in all six directions
- **THEN** it has no gussets

## REMOVED Requirements

### Requirement: Gussets on both faces
**Reason**: Not needed; the edge walls and the second gusset add material and complexity without a
use the target constructions require.
**Migration**: Use the default placement. A flat corner gets one gusset flush with the bottom.

### Requirement: Gussets don't block the stock
**Reason**: It cut a free channel through gussets that reached beyond the sockets; gussets now end
at the sockets, which the new requirement "Gussets end at the sockets" states.
**Migration**: None needed.
