# DimensionGate System

The **DimensionGate** is an Area3D that controls dimension swapping behavior. It has two modes: **Passive** (lock zone) and **Active** (portal).

## Overview

DimensionGates allow you to:
- Create zones where dimension swapping is disabled (static/locked zones)
- Create portals that force players into specific dimensions
- Build puzzles that require players to stay in a specific dimension
- Guide players through dimension-specific areas

## Modes

### Passive Mode (Dimension Lock Zone)

Prevents the player from swapping dimensions while inside the area.

**Use cases:**
- Boss arenas that must be completed in one dimension
- Puzzle areas that break if player switches dimensions
- Story sequences that need a specific dimension
- Safe zones where dimension changes are disabled

**Example:**
```gdscript
# A zone that locks dimension swapping
var gate = DimensionGate.new()
gate.mode = DimensionGate.GateMode.PASSIVE
gate.gate_size = Vector3(10, 5, 10)
```

**Visual:** Semi-transparent gray box with "DIMENSION LOCK ZONE" label

### Active Mode (Portal)

Forces the player to a specific dimension when they enter.

**Use cases:**
- Portals between dimension-specific areas
- Level transitions that change dimensions
- Forced dimension changes for story beats
- Puzzle solutions that reveal new dimension areas

**Example:**
```gdscript
# A portal that forces player into Viking dimension
var gate = DimensionGate.new()
gate.mode = DimensionGate.GateMode.ACTIVE
gate.target_dimension = DimensionManager.Dimension.VIKING
gate.force_once = true  # Only force on first entry
```

**Visual:** Semi-transparent colored box (color matches target dimension) with "PORTAL → [DIMENSION]" label

## Setup in Editor

### Basic Setup

1. Add a new **Area3D** node to your scene
2. Attach the `dimension_gate.gd` script
3. Configure in the Inspector:
   - **Mode**: PASSIVE or ACTIVE
   - **Target Dimension**: (ACTIVE mode only) Which dimension to force
   - **Gate Size**: The dimensions of the gate volume

The visual placeholder (mesh, collision, label) will automatically appear in the editor!

### Passive Gate Example

1. Add Area3D → Attach `dimension_gate.gd`
2. Set **Mode** = PASSIVE
3. Set **Gate Size** = (6, 4, 2) - wide archway
4. Position where you want the lock zone

When the player enters, they cannot press 1-4 to change dimensions until they exit.

### Active Gate (Portal) Example

1. Add Area3D → Attach `dimension_gate.gd`
2. Set **Mode** = ACTIVE
3. Set **Target Dimension** = VIKING (or any dimension)
4. Set **Force Once** = true (optional - prevents repeated forcing)
5. Position where you want the portal

When the player enters, they are immediately switched to the Viking dimension.

## Inspector Properties

### Gate Settings

- **Mode**: PASSIVE (lock) or ACTIVE (portal)
- **Target Dimension**: Which dimension to force (ACTIVE mode only)
  - NORMAL (gray)
  - VIKING (blue)
  - AZTEC (gold)
  - NIGHTMARE (red)

### Visual Settings

- **Gate Size**: Vector3 size of the gate volume (width, height, depth)
- **Passive Color**: Color tint for passive mode (default: gray)
- **Active Color**: Color tint for active mode (overridden by dimension color)

### Active Mode Settings

- **Force Once**: Only force dimension change on first entry (prevents repeated forcing if player re-enters)
- **Show Transition Effect**: Use the dimension transition shader (currently not implemented, reserved for future)

## Scripting API

### Check if player is inside

```gdscript
if dimension_gate.is_player_inside():
    print("Player is in the gate")
```

### Manually trigger the gate

```gdscript
# Force the gate effect (useful for scripted sequences)
dimension_gate.trigger()
```

### Change mode at runtime

```gdscript
# Switch from passive to active
dimension_gate.set_mode(DimensionGate.GateMode.ACTIVE)

# Change target dimension
dimension_gate.set_target_dimension(DimensionManager.Dimension.NIGHTMARE)
```

## Example Scenes

### passive_gate_example.tscn

A simple passive gate (6x4x2) that locks dimension swapping.

- Walk through it and try pressing 1-4
- You'll see "Dimension switch blocked" in console
- Exit the gate to unlock swapping again

### active_gate_example.tscn

A portal gate (4x5x1) that forces the player to Viking dimension.

- Walk through it in any dimension
- You'll be instantly switched to Viking dimension
- Walk back through (force_once is false by default, so it triggers each time)

## Level Design Tips

### Passive Gates

**Boss Arena:**
```
Place a passive gate covering the entire boss room.
Player must defeat boss in whatever dimension they entered with.
```

**Puzzle Room:**
```
Lock player in Normal dimension while solving a physics puzzle.
Switching to Viking might break the puzzle solution.
```

**Story Beat:**
```
Force player to stay in Nightmare dimension during a scary sequence.
```

### Active Gates

**Dimension Hub:**
```
Create 4 portals in a central room, each leading to a different dimension.
Players walk through to explore dimension-specific areas.
```

**Story Progression:**
```
Place a portal at the end of Normal dimension area.
Forces player into Viking dimension for the next chapter.
```

**Puzzle Solution:**
```
A switch in Normal dimension opens a portal to Aztec.
Walking through it reveals the Aztec version of the room with the key.
```

### Combining Both Modes

**Gauntlet Challenge:**
```
1. Portal forces player into Viking dimension
2. Immediately followed by passive gate (lock zone)
3. Player must complete Viking-specific challenge
4. Exit triggers another portal back to Normal
```

**Nested Zones:**
```
Large passive gate (entire area locked)
Inside: Multiple active portals to different dimension "rooms"
Each room is actually the same space in different dimensions
```

## Visual Customization

The placeholder mesh is automatically created and can be seen in the editor. The colors are:

- **Passive Mode**: Gray (0.5, 0.5, 0.5, 0.3)
- **Active Mode**: Dimension-specific colors:
  - Normal: Gray (0.7, 0.7, 0.7, 0.4)
  - Viking: Blue (0.3, 0.5, 1.0, 0.4)
  - Aztec: Gold (1.0, 0.8, 0.3, 0.4)
  - Nightmare: Red (0.8, 0.2, 0.2, 0.4)

You can customize these colors in the Inspector under **Visual Settings**.

## Technical Details

### How Passive Mode Works

1. When player enters the Area3D:
   - Sets `DimensionManager.dimension_locked = true`
   - Player's dimension switch input is blocked

2. When player exits:
   - Sets `DimensionManager.dimension_locked = false`
   - Player can swap dimensions again

### How Active Mode Works

1. When player enters the Area3D:
   - Checks current dimension vs target dimension
   - If different, calls `DimensionManager.switch_to(target_dimension)`
   - If `force_once` is true, won't force again until player exits and re-enters

2. The dimension change triggers all normal dimension systems:
   - DimensionObject mesh swaps
   - AtmosphereManager transitions
   - Audio crossfades
   - Transition shader effect

### Collision Setup

- **Collision Layer**: 0 (gate doesn't collide with anything)
- **Collision Mask**: 1 (detects player on layer 1)

The gate only triggers on bodies in the "player" group.

## Troubleshooting

**Gate doesn't trigger:**
- Ensure player is in the "player" group
- Check collision mask is set to 1
- Verify the player's collision layer is 1

**Passive mode doesn't lock:**
- Check console for "Dimension swapping LOCKED" message
- Verify DimensionManager.dimension_locked is being set
- Make sure player script checks dimension_locked before switching

**Active mode doesn't force:**
- Check console for "Forced dimension change" message
- Verify target_dimension is set correctly
- Check if force_once is preventing repeated forcing

**Visual placeholder not showing:**
- The script is @tool, so it should show automatically
- Try selecting the node and changing a property to refresh
- Check that PlaceholderMesh child node exists

## Next Steps

1. Add a passive gate to your test scene
2. Walk through and try dimension swapping (should be blocked)
3. Add an active gate portal
4. Walk through and watch dimension change automatically
5. Design your first dimension-locked puzzle room!
