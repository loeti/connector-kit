# screws Specification

## Purpose
Places screw holes that secure the stock in its socket: which faces get a hole, how many, where
along the socket, and whether the head is countersunk.

## Requirements

### Requirement: Screw holes follow the screw standard
Screw holes SHALL be derived from the screw definition (Helical), not from hand-picked diameters.
Countersunk screws follow ISO 10642 / DIN 7991, whose head diameter is twice the thread diameter.
The clearance is added to the hole and to the countersink.

#### Scenario: M3 with the default clearance
- **WHEN** an M3 countersunk screw is used with a clearance of 0.2
- **THEN** the through hole is 3.2 in diameter and the countersink is 6.2 at the surface

### Requirement: Countersink only where the wall can take it
The head SHALL be countersunk only if the wall is at least as thick as the head is tall;
otherwise the hole SHALL be a plain through hole, because a countersink deeper than the wall
would leave nothing for the head to bear on.

#### Scenario: Thick enough wall
- **WHEN** an M3 countersunk screw (head 1.5 tall) goes through a 2.4 wall
- **THEN** the head is countersunk

#### Scenario: Wall too thin
- **WHEN** an M3 countersunk screw goes through a 1.2 wall
- **THEN** the hole is a plain through hole

### Requirement: Screw holes don't cut into neighbouring geometry
The clearance above a countersunk head SHALL end at the socket surface, so it doesn't cut into
other sockets or gussets.

#### Scenario: Hole next to a gusset
- **WHEN** a screw hole lies on a socket face next to a gusset
- **THEN** the gusset is not cut by the head clearance

### Requirement: Face for a screw
Unless an arm specifies its screws, screws SHALL go on the first free face in the order top
(+Z), back (+Y), right (+X), front (−Y), left (−X), bottom (−Z), skipping faces along the arm's
own axis. A face is not free if a centered gusset splits it, because the gusset would block the
hole; a gusset flush with a hub face only touches the edge of a socket face and leaves it free.

#### Scenario: Three-way corner
- **WHEN** a connector has arms +X, +Y and +Z with automatic gussets
- **THEN** the screws of the +X and +Y arms go on top, and the screw of the +Z arm goes on +Y

#### Scenario: All faces blocked
- **WHEN** a connector has arms in all six directions with automatic gussets
- **THEN** the +X arm has no free face and gets no screw

### Requirement: Several screws per arm
With more than one screw per arm, screws SHALL alternate between the preferred face and the face
opposite it (if that one is free too) and be spread evenly along the socket (at 1/(n+1), 2/(n+1),
…), so that screws entering from opposite sides don't meet.

#### Scenario: Two screws
- **WHEN** a straight coupler along Y has two screws per arm
- **THEN** each arm has a screw on +Z at one third and a screw on −Z at two thirds of its depth

### Requirement: Screws hold stock that passes through the hub
When the stock passes through the hub along an axis that has no arm, the hub SHALL be treated as
a socket along that axis and get its own screws, following the same rules, on faces that have no
arm attached, because nothing else holds that stock. With an arm on the pass-through axis, that
arm's screws hold the stock and the hub gets none.

#### Scenario: Reducing sleeve
- **WHEN** a connector has no arms, passes 13 mm stock through along X, and has an outer size of 22
- **THEN** the hub gets a countersunk M3 screw on top, through its 4.4 wall

#### Scenario: Face taken by an arm
- **WHEN** the stock passes through along X and the only arm points +Z
- **THEN** the hub screw goes on +Y

#### Scenario: Arm on the pass-through axis
- **WHEN** the stock passes through along X and there is an arm on +X
- **THEN** the hub gets no screws
