# Tasks

## 1. Gusset geometry

- [x] 1.1 Add `reach` to `Gusset` and clip the quadrant box at `reach` along both arms; set it to hub size + socket depth in the layout; verify the three-way corner is 52 × 52 × 52 and a section through a gusset at the socket end shows it ending flush.
- [x] 1.2 Remove centered gussets from `gussetPlacements` (no gusset when the normal axis has arms in both directions) and the `isCentered` / `hasCenteredGusset` logic; verify with a rule test that arms ±X, ±Y, +Z give four gussets and arms in all six directions give none.
- [x] 1.3 Remove `GussetSides`, the `sides` of `GussetStyle.quarterDisc`, `GussetEdgeWall` and `gussetEdgeWalls`; verify the package builds.
- [x] 1.4 Remove `stockChannels` from the layout and `Connector`; verify the stock fit test passes for all target constructions and the six-way cross.

## 2. Screws

- [x] 2.1 Simplify `screwSides(for:)` to the preference order without the gusset check; verify the screw rule tests, with the six-way cross now getting its +X screw on top.

## 3. Customizer

- [x] 3.1 Remove the "Gusset sides" parameter and `GussetSidesChoice`, and update the description of "Gusset overhang"; verify `swift run` writes the default corner at 52 × 52 × 52.

## 4. Tests and documentation

- [x] 4.1 Remove the boxed corner from the target constructions and update the sizes (tee joining three stocks 77 × 52 × 27, corner with two stocks 52 × 52 × 27, corner with three stocks 52³); verify the target construction tests pass.
- [x] 4.2 Recompute the three-way corner's expected volume by hand (gusset area = square of 52 within the radius 60 disc minus the hub and socket footprint) and update the volume test; verify it passes within 0.5 %.
- [x] 4.3 Render the tee joining three stocks, a four-way cross and arms ±X, ±Y, +Z, and check that there are no tabs, slivers or pins.
- [x] 4.4 Update the README (constructions table without the boxed corner, new sizes, parameters table without "Gusset sides", gussets row in the specs table) and the title image; verify `openspec validate --all --strict` passes.

## Workflow follow-up

- Archive the change once the tests pass, which updates the gussets, screws, target-constructions and customizer specs.
