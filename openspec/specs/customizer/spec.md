# customizer Specification

## Purpose
Exposes the connector as one parametric model, built locally with default values and published as
a web customizer, instead of a fixed catalogue of connector variants.

## Requirements

### Requirement: One parametric model
The executable SHALL define a single model, "Connector", whose shape follows entirely from its
parameters. There SHALL be no list of predefined variants; every shape is a combination of
parameter values.

#### Scenario: Local build
- **WHEN** the executable runs without a customizer
- **THEN** it writes Models/Connector.3mf with the default parameters: a three-way corner with arms
  +X, +Y and +Z, 22 mm stock, outer size 27, socket depth 25, M3 screws and automatic gussets

### Requirement: Parameters
The model SHALL offer these parameters with these defaults: stock size 22, clearance 0.2, socket
depth 25, wall sizing by outer size 27 (or by wall thickness 2.4), minimum wall thickness 1.2, one
switch per arm direction (+X, +Y, +Z on), pass-through none, gussets on with overhang 8 and
automatic sides, M3 screws, one screw per arm, and show stock off. The clearance is applied as the
tolerance of the whole model.

#### Scenario: Straight coupler from parameters
- **WHEN** only the arms −Y and +Y are on, gussets are off and there are two screws per arm
- **THEN** the model is a 51 long straight coupler with a stop lip and two screws per arm

### Requirement: Parameters appear only when they apply
A parameter that depends on another one SHALL only be offered while it has an effect: the outer
size or the wall thickness depending on the wall sizing, the gusset overhang and sides only with
gussets on, and the number of screws only with screws.

#### Scenario: No screws
- **WHEN** screws are set to none
- **THEN** the number of screws per arm isn't offered

### Requirement: Inserted stock as reference only
With show stock on, the inserted stock SHALL be shown as a background part that isn't printed.

#### Scenario: Download
- **WHEN** show stock is on and the model is downloaded
- **THEN** the 3MF file marks the stock as not printable

### Requirement: Published customizer
Every push to main SHALL build the web customizer from the package and publish it on GitHub Pages.

#### Scenario: Push
- **WHEN** a change is pushed to main
- **THEN** https://loeti.github.io/connector-kit/ serves the customizer built from that commit

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
