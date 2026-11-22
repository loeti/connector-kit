# connector-layout Specification

## Purpose
Arranges a connector from a hub and sockets (arms) along any of the six axis directions, and
decides how the stock is stopped or passed through.

## Requirements

### Requirement: Arms along axis directions
A connector SHALL have at most one arm per axis direction (+X, −X, +Y, −Y, +Z, −Z). Each arm is a
socket that starts at the hub face and extends the socket depth outwards. Only square stock is
supported for now.

#### Scenario: Three-way corner
- **WHEN** a connector has arms +X, +Y and +Z, 22 mm stock, an outer size of 27 and a socket depth of 25
- **THEN** each arm reaches 13.5 + 25 = 38.5 from the center along its axis

### Requirement: The hub stops the stock
If the arms lie on more than one axis, the hub SHALL be a solid cube as wide as a socket's outer
size, centered at the origin, and the stock in each arm SHALL stop at the hub face.

#### Scenario: Stock butts against the hub
- **WHEN** stock is inserted into an arm of a three-way corner
- **THEN** it touches the hub face and doesn't overlap the connector

### Requirement: Stop lip in a straight connector
If all arms lie on one axis, the hub SHALL shrink along that axis to a stop lip: a ring 1 thick
that reaches 0.5 into the cavity from each wall, because a full hub would make a straight
connector needlessly long.

#### Scenario: Straight coupler
- **WHEN** a connector has arms −Y and +Y with a socket depth of 25
- **THEN** it is 2 × 25 + 1 = 51 long and its stop lip leaves an opening of 22.2 − 2 × 0.5 = 21.2

### Requirement: Stock passing through the hub
When a pass-through axis is set, the full inner cross-section SHALL be cut through the hub along
that axis, so stock can run straight through. In a straight connector along that axis there is no
hub and no stop lip at all, only a sleeve.

#### Scenario: Pass-through tee
- **WHEN** a connector has arms −X, +X and −Y and passes through along X
- **THEN** it is 77 long along X, the stock runs through, and the −Y arm stops at the wall of the
  through channel

#### Scenario: Plain sleeve
- **WHEN** a straight coupler along Y passes through along Y
- **THEN** it has no hub

#### Scenario: No arms
- **WHEN** a connector has no arms and passes through along X
- **THEN** it is a cube as wide as a socket with a square hole along X (see screws for how the
  stock is held)

### Requirement: Inserted stock for reference
The layout SHALL provide the inserted stock as reference geometry: one piece per arm, starting at
the hub face (or the stop lip), plus a piece through the hub along the pass-through axis. It is
used for display and fit tests and is never part of the printed connector.

#### Scenario: Fit
- **WHEN** the inserted stock of any connector is intersected with the connector
- **THEN** the intersection has no volume

### Requirement: Valid pass-through axes
A pass-through axis SHALL be used only if the connector has arms in both directions along it, or
if the connector has no arms at all, because only then does the stock run through sockets on both
sides or through a reducing sleeve. Otherwise the pass-through SHALL be ignored and the connector
built as without it.

#### Scenario: Through tee
- **WHEN** a connector has arms −X, +X and −Y and passes through along X
- **THEN** the stock along X runs through the hub

#### Scenario: Reducing sleeve
- **WHEN** a connector has no arms and passes through along Y
- **THEN** the stock along Y runs through the hub

#### Scenario: No arm on the axis
- **WHEN** a connector has only the arm +Z and passes through along X
- **THEN** the pass-through is ignored and the connector is a hub with one socket on +Z

#### Scenario: Arms on other axes only
- **WHEN** a connector has arms +X and +Z and passes through along Y
- **THEN** the pass-through is ignored

#### Scenario: Arm in one direction only
- **WHEN** a connector has arms +X and +Y and passes through along X
- **THEN** the pass-through is ignored and the +X stock stops at the hub
