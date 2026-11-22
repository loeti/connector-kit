# cut-lengths Specification

## Purpose
Makes stock cut lengths easy to work out: every connector states where the stock ends, so the
length of each piece follows from the frame dimensions with a simple deduction.

## Requirements

### Requirement: Frame dimensions are measured over the connectors
Frame dimensions SHALL be stated over the outside of the connectors, because that is the size the
user plans with; stock lengths are derived from them.

#### Scenario: Box planned by its outer size
- **WHEN** a user plans a box of 1000 × 600 × 500
- **THEN** 1000, 600 and 500 are the dimensions over the outside of the corner connectors

### Requirement: Stop distance
For each arm, the stop distance SHALL be the distance from the connector's center to the end of
the inserted stock: half the hub size where the stock stops at the hub. Stock that passes through
has no stop distance.

#### Scenario: Hub stop
- **WHEN** a connector with a 27 hub has arms on more than one axis
- **THEN** the stop distance of each arm is 13.5

### Requirement: Deductions within the cutting tolerance count as zero
A deduction smaller than the cutting tolerance of 1 SHALL count as zero for cut lengths, because
wooden stock is not cut more accurately than that. This applies to the stop lip of a straight
connector, so an extension adds no length.

#### Scenario: Stop lip
- **WHEN** a connector has only the arms −Y and +Y with the 1 thick stop lip
- **THEN** the stop distance used for cut lengths is 0, although the lip is 0.5 on each side

### Requirement: Outer offset
For each arm whose opposite direction has no arm, the outer offset SHALL be the distance from the
connector's outer face on the opposite side to the end of the stock in that arm, which is the hub
size, so a frame can be measured over the outside of its connectors.

#### Scenario: Corner
- **WHEN** a three-way corner has a 27 hub
- **THEN** the outer offset of each arm is 27

### Requirement: Cut length from frame dimensions
A stock between two connectors SHALL be cut to the frame dimension minus the deduction at each end:
the outer offset at a connector the dimension is measured over, and the stop distance at a
connector the dimension is measured to the center of (such as a tee within a side). The deduction SHALL NOT depend on the
clearance, the screws or the gussets.

#### Scenario: Box of 1000 × 600 × 500 with three-way corners
- **WHEN** a box measuring 1000 × 600 × 500 over the outside of its eight corners is built from
  22 mm stock with the default 27 hub
- **THEN** its stocks are cut to 4 × 946, 4 × 546 and 4 × 446, because each stock loses 2 × 27

#### Scenario: Tee in the middle of a side
- **WHEN** a side of 1000 over the outside of its corners has a tee whose center is at 500
- **THEN** both stocks of that side are cut to 500 − 27 − 13.5 = 459.5

#### Scenario: Extension
- **WHEN** a length of 2000 is made from two stocks joined by an extension
- **THEN** each stock is cut to 1000

#### Scenario: Clearance changes
- **WHEN** the clearance changes from 0.2 to 0.4 and the outer size stays 27
- **THEN** the stop distance and outer offset stay 13.5 and 27

### Requirement: Larger hub when the minimum wall applies
When the minimum wall thickness makes a socket larger than the requested outer size, the stop
distance and the outer offset SHALL follow the actual hub size, not the requested one.

#### Scenario: 25 mm stock in a 27 outer size
- **WHEN** 25 mm stock is used with an outer size of 27 and the wall grows to 1.2
- **THEN** the hub is 27.6, the stop distance is 13.8 and the outer offset is 27.6
