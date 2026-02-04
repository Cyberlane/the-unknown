# Greybox Demo Level

This level demonstrates three core systems working together:
1. **Scene Transition** - LevelRegion proximity-based loading
2. **Persistence** - Object state that survives dimension changes and scene reloads
3. **Voice Trigger** - Dimension-specific audio/dialogue

## What's in the Level

### Scene Structure

```
greybox_demo.tscn (Main scene)
├── Player (spawns at origin)
├── HallwayRegion (Node3D at z=-5)
│   ├── 4 hallway sub-scenes (one per dimension)
│   └── Viking hallway has persistent box
└── RoomRegion (Node3D at z=-30)
    ├── 4 room sub-scenes (one per dimension)
    └── Aztec room has voice trigger
```

### 1. Scene Transition (LevelRegion)

Two LevelRegion nodes demonstrate proximity-based level streaming:

- **HallwayRegion** (z=-5)
  - Loads when player is within 30m
  - Unloads when player is beyond 50m
  - 4 hallway variants (gray, blue, gold, red)

- **RoomRegion** (z=-30)
  - Loads when player walks forward into hallway
  - Automatically swaps active sub-scene when dimension changes
  - 4 room variants with walls on all sides

**Test it:**
1. Run the scene - hallway loads immediately (you're close to it)
2. Walk backwards - watch console for "region_unloaded" message
3. Walk forward through hallway toward room
4. Watch console for "region_loaded" as room loads
5. Switch dimensions (1-4) - watch sub-scenes swap

### 2. Persistence (Movable Box)

The Viking hallway contains a persistent box that remembers its position.

**Location:** Viking dimension (press 2), hallway, z=-5

**What it does:**
- Push the box by walking into it
- Position saves every 0.5 seconds when moving
- Switch to another dimension
- Switch back to Viking - box is in the same place!
- Walk away until hallway unloads
- Walk back - box position is restored!

**Test it:**
1. Press **2** to enter Viking dimension
2. Walk forward into hallway
3. Find the blue box with "PUSH ME!" label
4. Walk into the box to push it to one side
5. Press **1** to switch to Normal dimension (box disappears)
6. Press **2** again - box is back in the pushed position!
7. Walk backwards until "region_unloaded" message appears
8. Walk forward again - box is still in the pushed position!

**Technical:**
- Uses `persistent_box.gd` script
- Box ID: `"greybox_hallway_crate_01"`
- Saves position/rotation to PersistenceManager
- Restores state in `_ready()` when scene reloads

### 3. Voice Trigger (Aztec Room)

The Aztec room has a dimension-specific trigger that only activates in Aztec dimension.

**Location:** Aztec dimension (press 3), room at z=-30

**What it does:**
- Enter the room in Normal/Viking/Nightmare - nothing happens
- Switch to Aztec dimension (press 3)
- Enter the room - hear an ancient voice!
- Trigger is one-shot, so it only activates once per session

**Test it:**
1. Walk forward through hallway to reach the room
2. Press **1, 2, or 4** (Normal, Viking, or Nightmare)
3. Enter the room - nothing happens
4. Press **3** to switch to Aztec dimension
5. Room turns golden, and you hear: *"The sun guides those who seek truth..."*
6. Check console for "Aztec voice triggered!" message

**Technical:**
- Uses `DimensionTrigger` set to `active_dimension = AZTEC`
- Uses `voice_trigger.gd` helper to show dialogue
- `one_shot = true` prevents repeated triggering
- Message auto-dismisses after 5 seconds

## How to Run

1. Open `scenes/levels/greybox_demo.tscn` in Godot
2. Press **F5** or click Run Current Scene
3. Follow the instructions on the floating label

## Controls

- **WASD**: Move
- **Mouse**: Look around
- **Space**: Jump
- **1-4**: Switch dimensions (Normal, Viking, Aztec, Nightmare)
- **ESC**: Release mouse

## Expected Behavior

### Scene Transition Test
```
1. Start scene → "HallwayRegion: region_loaded (dimension 0)"
2. Walk backwards → "HallwayRegion: region_unloaded"
3. Walk forward → "HallwayRegion: region_loaded (dimension 0)"
4. Continue forward → "RoomRegion: region_loaded (dimension 0)"
5. Press 2 (Viking) → Both regions swap to Viking variants
```

### Persistence Test
```
1. Press 2 (Viking)
2. Push box to position (0, 1.5, -8)
3. Walk away → Region unloads
4. Walk back → Box at (0, 1.5, -8) ✓
5. Press 1 (Normal) → Box disappears
6. Press 2 (Viking) → Box back at (0, 1.5, -8) ✓
```

### Voice Trigger Test
```
1. Press 1 (Normal) + Enter room → (silence)
2. Press 3 (Aztec) + Enter room → "The sun guides..." ✓
3. Exit and re-enter → (no message - one-shot) ✓
```

## File Structure

```
scenes/levels/
├── greybox_demo.tscn           # Main demo scene
├── greybox_chunks/
│   ├── hallway_normal.tscn     # Gray hallway
│   ├── hallway_viking.tscn     # Blue hallway with persistent box
│   ├── hallway_aztec.tscn      # Gold hallway
│   ├── hallway_nightmare.tscn  # Red hallway
│   ├── room_normal.tscn        # Gray room
│   ├── room_viking.tscn        # Blue room
│   ├── room_aztec.tscn         # Gold room with voice trigger
│   └── room_nightmare.tscn     # Red room
└── README.md (this file)

scripts/
├── level_region.gd             # Proximity-based level streaming
├── persistent_box.gd           # Movable box that saves position
├── voice_trigger.gd            # Helper for dimension-specific voices
└── autoload/
    └── persistence_manager.gd  # Global state tracking
```

## Debug Mode

Both LevelRegions have `debug_mode = true`, so you'll see console messages:

```
HallwayRegion: Checking distance to player: 12.5m
HallwayRegion: region_loaded (dimension: 0)
HallwayRegion: Distance to player: 55.3m
HallwayRegion: region_unloaded
RoomRegion: region_loaded (dimension: 0)
DimensionTrigger 'AztecVoiceTrigger': Aztec voice triggered!
PersistentBox 'greybox_hallway_crate_01': Restored position (0, 1.5, -8)
```

## Extending the Demo

### Add more rooms:
1. Create new room chunk scenes (4 variants per room)
2. Add a new LevelRegion node at a new position
3. Assign the 4 room variants to the region

### Add more persistent objects:
1. Duplicate the persistent box
2. Change the `box_id` to something unique (e.g., `"greybox_room_crate_01"`)
3. Test pushing it and switching dimensions

### Add more voice triggers:
1. Add a DimensionTrigger to any scene
2. Set `active_dimension` to desired dimension
3. Add VoiceTrigger script as child
4. Set `voice_message` to your text

## Troubleshooting

**Hallway doesn't load:**
- Check player is within 30m of HallwayRegion (at z=-5)
- Verify player is in "player" group
- Enable debug_mode to see distance checks

**Box doesn't stay moved:**
- Check console for "PersistentBox: Restored position" message
- Verify box_id is not empty: `"greybox_hallway_crate_01"`
- Make sure you're pushing it far enough (0.5s save interval)

**Voice doesn't trigger:**
- Make sure you're in Aztec dimension (press 3)
- Enter the room (walk into the center)
- Check console for "Aztec voice triggered!" message
- Remember it's one-shot - only triggers once

**Scenes don't swap when changing dimension:**
- Check that all 4 sub-scenes are assigned in LevelRegion
- Verify DimensionManager is loaded (autoload)
- Enable debug_mode to see dimension swaps

## Next Steps

This demo is a foundation for building your full game. You can:

1. Replace greybox geometry with real art assets
2. Add more LevelRegions to build larger interconnected areas
3. Create persistent doors, switches, and pickups
4. Add dimension-specific puzzles using DimensionTrigger
5. Design encounters that require dimension swapping
6. Build a full level using this pattern!
