# Tasks

## 1. Effective pass-through axis

- [x] 1.1 Add `passThroughAxis` (effective) and `ignoredPassThroughAxis` to `ConnectorLayout` and use the effective axis everywhere instead of `configuration.passThroughAxis`; verify with rule tests for all spec scenarios (through tee, reducing sleeve, +Z with X, +X/+Z with Y, +X/+Y with X).
- [x] 1.2 Add a geometry test that a connector with an ignored pass-through is identical in volume to the same connector without pass-through; verify it fails before 1.1 by building with `+Z` and pass-through X.

## 2. Hub screws

- [x] 2.1 Limit `passThroughHubSocket` to connectors without arms and remove the now unreachable arm-face filtering; replace the rule test "Hub screws avoid faces that have an arm" with tests for the reducing sleeve (screw on top) and the through tee (no hub screws); verify they pass.

## 3. Customizer description

- [x] 3.1 Add the ignored pass-through line to `CutLengthReport`; verify with report tests for +Z with pass-through X (line present) and the through tee (line absent).
- [x] 3.2 Build the customizer locally and verify with `model.wasm` that choosing +Z only with pass-through X shows the line and builds a plain one-arm connector.

## 4. Documentation

- [x] 4.1 Update the README pass-through row in the parameters table to state when it applies; verify `openspec validate --all --strict` passes.

## Workflow follow-up

- Archive the change once the tests pass, which updates the connector-layout, screws and customizer specs.
