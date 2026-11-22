## MODIFIED Requirements

### Requirement: Parameters
The model SHALL offer these parameters with these defaults: stock size 22, clearance 0.2, socket
depth 25, wall sizing by outer size 27 (or by wall thickness 2.4), minimum wall thickness 1.2, one
switch per arm direction (+X, +Y, +Z on), pass-through none, gussets on with overhang 8, M3 screws,
one screw per arm, and show stock off. The clearance is applied as the tolerance of the whole model.

#### Scenario: Straight coupler from parameters
- **WHEN** only the arms −Y and +Y are on, gussets are off and there are two screws per arm
- **THEN** the model is a 51 long straight coupler with a stop lip and two screws per arm

### Requirement: Parameters appear only when they apply
A parameter that depends on another one SHALL only be offered while it has an effect: the outer
size or the wall thickness depending on the wall sizing, the gusset overhang only with gussets on,
and the number of screws only with screws.

#### Scenario: No screws
- **WHEN** screws are set to none
- **THEN** the number of screws per arm isn't offered
