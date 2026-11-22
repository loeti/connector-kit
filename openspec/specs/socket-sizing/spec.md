# socket-sizing Specification

## Purpose
Derives the dimensions of a socket from the stock that goes into it, the clearance of the fit
and a wall rule, so that every part sized from these rules fits the same stock.

## Requirements

### Requirement: Stock is a material-independent cross-section
Stock SHALL be described only by its cross-section (width and height), without a material or a
name, because the same sizes apply to wood, tubes and extrusions. Both dimensions MUST be
positive.

#### Scenario: Square stock
- **WHEN** stock is created with a size of 22
- **THEN** its width and height are both 22 and it counts as square

### Requirement: Inner size includes the clearance
The inner size of a socket SHALL be the stock size plus the total clearance, so the stock slides
in with half the clearance on each side.

#### Scenario: Default clearance
- **WHEN** 22 mm stock goes into a socket with a clearance of 0.2
- **THEN** the inner size is 22.2

### Requirement: Wall thickness from an outer size
When the wall rule targets an outer size, the wall thickness SHALL be
`(outer size − stock size − clearance) / 2`, using the larger stock dimension, so sockets for
different stock can share one outer size.

#### Scenario: Reference socket
- **WHEN** 22 mm stock, a clearance of 0.2 and an outer size of 27 are used
- **THEN** the wall is 2.4 thick, because 2.4 + 0.1 + 22 + 0.1 + 2.4 = 27

### Requirement: Wall thickness given directly
When the wall rule targets a thickness, the wall SHALL have that thickness and the outer size
SHALL follow from it.

#### Scenario: Fixed wall
- **WHEN** 30 mm stock, a clearance of 0.4 and a wall thickness of 2 are used
- **THEN** the outer size is 34.4

### Requirement: Minimum wall thickness
The wall SHALL never be thinner than the minimum wall thickness (default 1.2), for either kind of
wall rule, because thinner walls don't print reliably. If the rule asks for less, the minimum is
used, the socket grows beyond the requested outer size, and the dimensions report that the
minimum was applied.

#### Scenario: Stock too large for the outer size
- **WHEN** 25 mm stock, a clearance of 0.2 and an outer size of 27 are used
- **THEN** the requested wall would be 0.9, so the wall is 1.2, the outer size is 27.6 and the
  minimum is reported as applied

#### Scenario: Fixed wall below the minimum
- **WHEN** a wall thickness of 0.8 is requested
- **THEN** the wall is 1.2
