# Proposal

## Why

Pass-through can be chosen along any axis, which allows constructions that make no sense: with
only an arm on +Z, passing stock through along X or Y runs it across the hub without any socket
guiding it; the same goes for arms ±Z with pass-through X or Y, or arms +X and +Z with
pass-through Y. Even with a single arm on the axis (arm +X, pass-through X), the stock would leave
the hub at the back without a socket. Stock running through a connector only makes sense where
sockets guide it on both sides, or in a reducing sleeve, which has no arms at all.

## What Changes

- **BREAKING** Pass-through is valid only along an axis with arms in both directions, or along any
  axis when the connector has no arms (reducing sleeve).
- An invalid pass-through is ignored: the connector is built as without pass-through.
- The customizer description says when and why a pass-through was ignored.
- Screws in the hub only remain for the reducing sleeve; with a valid pass-through on a connector
  with arms, the arms along that axis hold the stock.

## Capabilities

### New Capabilities

None.

### Modified Capabilities
- `connector-layout`: which pass-through axes are valid, and that an invalid one is ignored.
- `screws`: hub screws only for the reducing sleeve.
- `customizer`: the description explains an ignored pass-through.

## Impact

- Library: the layout resolves an effective pass-through axis and uses it everywhere the configured
  one was used (hub openings, stop distances, stock pieces, hub screws); it exposes why a
  configured axis was ignored.
- Customizer: no new parameter; the description gets one more line when needed.
- Tests: valid and invalid combinations, including the three examples above.
