## ADDED Requirements

### Requirement: Preferred face for a screw
Unless an arm specifies its screws, screws SHALL go on the first face in the order top (+Z), back
(+Y), right (+X), front (−Y), left (−X), bottom (−Z), skipping faces along the arm's own axis,
because the top is easiest to reach. Gussets don't block a face: they sit flush with a hub face and
only touch the edge of a socket face.

#### Scenario: Three-way corner
- **WHEN** a connector has arms +X, +Y and +Z with gussets
- **THEN** the screws of the +X and +Y arms go on top, and the screw of the +Z arm goes on +Y

#### Scenario: Arms in all six directions
- **WHEN** a connector has arms in all six directions
- **THEN** the +X arm's screw goes on top

## REMOVED Requirements

### Requirement: Face for a screw
**Reason**: It skipped faces split by centered gussets, which no longer exist; replaced by
"Preferred face for a screw".
**Migration**: None needed; without centered gussets both rules place screws on the same faces,
except where the old rule found no free face, which now gets a screw on top.
