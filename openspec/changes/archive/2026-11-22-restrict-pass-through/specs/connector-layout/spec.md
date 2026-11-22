## ADDED Requirements

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
