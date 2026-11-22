## ADDED Requirements

### Requirement: Ignored pass-through is explained
When the chosen pass-through is ignored, the model description SHALL say so and why, because the
pass-through choice can't be limited to the valid axes in the form.

#### Scenario: No arms along the axis
- **WHEN** only the arm +Z is on and the pass-through is X
- **THEN** the description states that the pass-through along X is ignored because it needs arms in
  both directions along X

#### Scenario: Valid pass-through
- **WHEN** the arms −X, +X and −Y are on and the pass-through is X
- **THEN** the description doesn't mention an ignored pass-through
