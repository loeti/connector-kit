# Spec Delta

## ADDED Requirements

### Requirement: Customizer reports cut-length deductions
The model description SHALL report, for the current parameters, the stop distance and the outer
offset of the arms, the deduction per stock for a frame measured over the connectors, and which
axis the stock passes through, if any, so the user can work out cut lengths without measuring the
model.

#### Scenario: Default corner
- **WHEN** the customizer shows the default three-way corner
- **THEN** the description states that the stock ends 13.5 from the connector's center and 27 from
  its outer face, so a stock between two such corners is cut 54 shorter than the frame dimension

#### Scenario: Extension
- **WHEN** only the arms −Y and +Y are on
- **THEN** the description states that the stocks are cut to the total length, as the stop lip is
  within the cutting tolerance

#### Scenario: Pass-through
- **WHEN** the stock passes through along X
- **THEN** the description states that the stock along X runs through without a stop
