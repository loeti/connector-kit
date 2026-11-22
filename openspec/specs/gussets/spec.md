# gussets Specification

## Purpose
Braces pairs of perpendicular arms with quarter-disc plates, placed so they add stiffness without
blocking the stock or the screws.

## Requirements

### Requirement: Quarter-disc gusset per pair of perpendicular arms
Each pair of perpendicular arms SHALL be braced by a quarter disc centered on the hub corner
opposite both arms, as thick as the socket wall. Its radius SHALL reach the gusset overhang
(default 8) beyond the socket ends, measured along the back edge.

#### Scenario: Reference corner
- **WHEN** 27 mm sockets with a depth of 25 and an overhang of 8 are used
- **THEN** the gusset radius is 27 + 25 + 8 = 60 and the connector is 60 × 60 × 60

### Requirement: Automatic placement along the third axis
With automatic sides, each gusset SHALL sit flush with a hub face along the axis perpendicular to
its two arms: on the − side if that axis only has an arm in + direction (and vice versa), which
gives a corner connector flat back faces; on the − side if that axis has no arm, which gives a
flat bottom for printing; and centered if that axis has arms in both directions.

#### Scenario: Flat back faces
- **WHEN** a connector has arms +X, +Y and +Z
- **THEN** each of its three gussets is flush with the hub face on the − side of its third axis

#### Scenario: Arms in both directions
- **WHEN** a connector has arms in all six directions
- **THEN** every gusset is centered on the hub

### Requirement: Gussets on both faces
With both sides, there SHALL be a gusset flush with each of the two hub faces along the third
axis, and walls as thick as the socket wall SHALL join them along the straight edges of the
quarter disc, from the socket end to the rim, so the space between the arms becomes a box
section.

#### Scenario: Boxed elbow
- **WHEN** a connector has arms +X and +Y with gussets on both sides
- **THEN** it has a gusset at the top and at the bottom, joined by an 8 mm wall beyond the end of
  each socket, and it is 60 × 60 × 27

### Requirement: Gussets don't block the stock
The inner cross-section of each arm SHALL be kept free from the hub face out to where the gussets
end, because a gusset reaching beyond a socket would otherwise block the stock where it leaves the
socket.

#### Scenario: Centered gussets
- **WHEN** a connector has arms in all six directions and stock longer than the sockets is inserted
- **THEN** the stock doesn't overlap any gusset
