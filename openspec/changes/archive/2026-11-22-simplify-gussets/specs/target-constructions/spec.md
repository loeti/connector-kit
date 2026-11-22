## MODIFIED Requirements

### Requirement: Tee joining three stocks
The kit SHALL produce a tee that joins three stocks, all ending at the hub: arms −X, +X and +Y.

#### Scenario: Tee with gussets
- **WHEN** a connector has arms −X, +X and +Y
- **THEN** it is 77 × 52 × 27, braced by two gussets flush with the bottom that end at the socket
  ends, with each stock stopping at the hub and one screw on top of each arm

### Requirement: Corner with two stocks
The kit SHALL produce a flat 90° corner of two stocks: arms +X and +Y.

#### Scenario: Elbow
- **WHEN** a connector has arms +X and +Y
- **THEN** it is 52 × 52 × 27 with one gusset flush with the bottom and one screw on top of each arm

### Requirement: Corner with three stocks
The kit SHALL produce a three-way corner of three perpendicular stocks: arms +X, +Y and +Z.

#### Scenario: Three-way corner
- **WHEN** a connector has arms +X, +Y and +Z
- **THEN** it is 52 × 52 × 52 with flat back faces on the −X, −Y and −Z sides, screws on top of the
  +X and +Y arms, and the screw of the +Z arm on +Y

## REMOVED Requirements

### Requirement: Boxed corner with two stocks
**Reason**: Gussets on both faces are removed from the kit.
**Migration**: Use the corner with two stocks.
