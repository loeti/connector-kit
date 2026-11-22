## ADDED Requirements

### Requirement: Screws hold the stock in a reducing sleeve
In a connector without arms whose stock passes through, the hub SHALL be treated as a socket along
the pass-through axis and get its own screws, following the same rules as arms, because nothing
else holds that stock. Connectors with arms get no screws in the hub; a valid pass-through has arms
on both sides, whose screws hold the stock.

#### Scenario: Reducing sleeve
- **WHEN** a connector has no arms, passes 13 mm stock through along X, and has an outer size of 22
- **THEN** the hub gets a countersunk M3 screw on top, through its 4.4 wall

#### Scenario: Through tee
- **WHEN** a connector has arms −X, +X and −Y and passes through along X
- **THEN** the hub gets no screws and each arm has its own

## REMOVED Requirements

### Requirement: Screws hold stock that passes through the hub
**Reason**: Pass-through along an axis without arms is now only valid for the reducing sleeve; the
other cases it covered (pass-through next to an arm on another axis, or with one arm on the axis)
are ignored.
**Migration**: Replaced by "Screws hold the stock in a reducing sleeve".
