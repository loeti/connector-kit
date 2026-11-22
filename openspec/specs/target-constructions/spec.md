# target-constructions Specification

## Purpose
Names the constructions the connector kit must be able to produce from its parameters, each with
the parameter values that produce it and the dimensions it must have, so completeness and
regressions can be checked against concrete targets.

## Requirements

### Requirement: Default socket for target constructions
Unless a construction states otherwise, every target construction SHALL use 22 mm stock, an outer
size of 27, a socket depth of 25, a clearance of 0.2, M3 countersunk screws with one screw per arm,
and automatic gussets with an overhang of 8, because these are the customizer defaults and the
dimensions below are derived from them.

#### Scenario: Socket of a target construction
- **WHEN** any target construction is built with these values
- **THEN** each socket has a 22.2 opening and a 2.4 wall

### Requirement: Every target construction is one printable piece
Every target construction SHALL be a single connected solid, and the inserted stock SHALL NOT
overlap it, because each construction is printed in one piece and must take its stock.

#### Scenario: Any target construction
- **WHEN** a target construction is built and its inserted stock is intersected with it
- **THEN** the construction is one piece and the intersection has no volume

### Requirement: Reducing sleeve
The kit SHALL produce a reducing sleeve that adapts smaller stock to a larger socket: no arms,
the stock passing through along X, 13 mm stock and an outer size of 22.

#### Scenario: 13 mm stock into a 22 mm socket
- **WHEN** a connector has no arms, passes through along X, 13 mm stock and an outer size of 22
- **THEN** it is 22 × 22 × 22 with a 13.2 square opening along X and one countersunk screw on top

### Requirement: Extension of two stocks
The kit SHALL produce an extension that joins two stocks end to end: arms −Y and +Y with two
screws per arm.

#### Scenario: Extension
- **WHEN** a connector has arms −Y and +Y and two screws per arm
- **THEN** it is 27 × 51 × 27, the stocks meet at a stop lip with a 21.2 opening, and it has four
  screw holes, two on top and two at the bottom

### Requirement: Tee joining three stocks
The kit SHALL produce a tee that joins three stocks, all ending at the hub: arms −X, +X and +Y.

#### Scenario: Tee with gussets
- **WHEN** a connector has arms −X, +X and +Y
- **THEN** it is 93 × 60 × 27, braced by two gussets flush with the bottom, with each stock stopping
  at the hub and one screw on top of each arm

### Requirement: Tee joining a stock to a perpendicular stock
The kit SHALL produce a tee that joins a stock to a perpendicular second stock, the first one
running straight through: arms −X, +X and −Y, passing through along X, without gussets.

#### Scenario: Through tee
- **WHEN** a connector has arms −X, +X and −Y, passes through along X and has no gussets
- **THEN** it is 77 × 52 × 27, the stock along X runs through the hub, the stock along −Y stops at
  the through channel, and each arm has one screw on top

### Requirement: Corner with two stocks
The kit SHALL produce a flat 90° corner of two stocks: arms +X and +Y.

#### Scenario: Elbow
- **WHEN** a connector has arms +X and +Y
- **THEN** it is 60 × 60 × 27 with one gusset flush with the bottom and one screw on top of each arm

### Requirement: Boxed corner with two stocks
The kit SHALL produce a flat 90° corner of two stocks that is closed into a box section: arms +X and
+Y with gussets on both sides.

#### Scenario: Boxed elbow
- **WHEN** a connector has arms +X and +Y and gussets on both sides
- **THEN** it is 60 × 60 × 27 with gussets at the top and the bottom, joined by walls along their
  straight edges beyond the sockets

### Requirement: Corner with three stocks
The kit SHALL produce a three-way corner of three perpendicular stocks: arms +X, +Y and +Z.

#### Scenario: Three-way corner
- **WHEN** a connector has arms +X, +Y and +Z
- **THEN** it is 60 × 60 × 60 with flat back faces on the −X, −Y and −Z sides, screws on top of the
  +X and +Y arms, and the screw of the +Z arm on +Y
