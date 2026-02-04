# PersistenceManager - Object State Persistence System

The **PersistenceManager** is a global singleton that tracks object states (collected, opened, activated, etc.) across dimension changes and LevelRegion scene reloads.

## Overview

When you have pickups, doors, switches, or any interactive object that should remember its state:
1. Give it a unique ID
2. Register it with PersistenceManager
3. Query/update its state through the manager
4. The state persists across dimension changes and scene reloads

## Basic Usage

### Example 1: Simple Pickup

```gdscript
extends Area3D

@export var pickup_id: String = "forest_health_potion_01"

func _ready():
    # Check if already collected
    if PersistenceManager.is_collected(pickup_id):
        queue_free() # Already picked up, remove from scene
        return

    # Register if not tracked
    if not PersistenceManager.has_object_state(pickup_id):
        PersistenceManager.register_object(pickup_id, {"collected": false})

func _on_player_interact():
    # Mark as collected
    PersistenceManager.mark_as_collected(pickup_id)

    # Give item to player, play effects, etc.
    print("Health potion collected!")
    queue_free()
```

### Example 2: Persistent Door

```gdscript
extends Node3D

@export var door_id: String = "castle_main_door"

func _ready():
    # Check if door was previously opened
    if PersistenceManager.is_opened(door_id):
        _set_door_open(true) # Open immediately without animation
    else:
        PersistenceManager.register_object(door_id, {"opened": false})

func _on_player_unlock():
    # Mark as opened
    PersistenceManager.mark_as_opened(door_id)

    # Animate door opening
    _set_door_open(true)
```

### Example 3: Custom State Tracking

```gdscript
extends StaticBody3D

@export var puzzle_id: String = "temple_crystal_puzzle"

func _ready():
    # Register with custom state structure
    if not PersistenceManager.has_object_state(puzzle_id):
        PersistenceManager.register_object(puzzle_id, {
            "crystals_placed": 0,
            "solved": false,
            "reward_claimed": false
        })

    # Restore state
    _restore_puzzle_state()

func _on_crystal_placed():
    var current = PersistenceManager.get_object_property(puzzle_id, "crystals_placed", 0)
    PersistenceManager.set_object_property(puzzle_id, "crystals_placed", current + 1)

    if current + 1 >= 3:
        PersistenceManager.set_object_property(puzzle_id, "solved", true)
        _show_reward()

func _restore_puzzle_state():
    var state = PersistenceManager.get_object_state(puzzle_id)

    # Restore crystals
    for i in range(state.get("crystals_placed", 0)):
        _place_crystal_visual(i)

    # Show reward if already solved
    if state.get("solved", false):
        _show_reward()
```

## Core API Reference

### Registration

```gdscript
# Register object with optional initial state
PersistenceManager.register_object("unique_id", {"key": "value"})

# Check if object is registered
if PersistenceManager.has_object_state("unique_id"):
    print("Object is tracked")
```

### State Management

```gdscript
# Get entire state dictionary
var state = PersistenceManager.get_object_state("unique_id")

# Set entire state (replaces existing)
PersistenceManager.set_object_state("unique_id", {"collected": true, "timestamp": 123})

# Update specific keys (merges with existing)
PersistenceManager.update_object_state("unique_id", {"collected": true})
```

### Property Access

```gdscript
# Get specific property with default fallback
var collected = PersistenceManager.get_object_property("unique_id", "collected", false)

# Set specific property
PersistenceManager.set_object_property("unique_id", "collected", true)
```

### Common Helpers

```gdscript
# Pickups
PersistenceManager.mark_as_collected("health_potion_01")
if PersistenceManager.is_collected("health_potion_01"):
    print("Already collected")

# Doors/Chests
PersistenceManager.mark_as_opened("treasure_chest_01")
if PersistenceManager.is_opened("treasure_chest_01"):
    print("Already opened")

# Switches/Levers
PersistenceManager.mark_as_activated("lever_01")
if PersistenceManager.is_activated("lever_01"):
    print("Already activated")
```

## Unique ID Guidelines

Each object MUST have a globally unique ID. Use a naming convention like:

```
area_type_name_number
```

Examples:
- `"forest_entrance_health_potion_01"`
- `"castle_main_door"`
- `"dungeon_level1_chest_03"`
- `"temple_crystal_puzzle"`

**Never use duplicate IDs** - the system will warn you if you try to register the same ID twice.

## Save/Load to Disk

The PersistenceManager can save all tracked states to a JSON file:

```gdscript
# Save all object states
PersistenceManager.save_to_file("user://save_game_slot_1.save")

# Load all object states
PersistenceManager.load_from_file("user://save_game_slot_1.save")

# Clear all states (for new game)
PersistenceManager.clear_all_states()
```

Default save location: `user://object_states.save`

## Signals

Connect to signals for reactive behavior:

```gdscript
func _ready():
    PersistenceManager.object_state_changed.connect(_on_any_object_changed)
    PersistenceManager.object_state_registered.connect(_on_object_registered)

func _on_any_object_changed(object_id: String, new_state: Dictionary):
    print("Object '%s' changed: %s" % [object_id, new_state])

func _on_object_registered(object_id: String):
    print("New object registered: %s" % object_id)
```

## Debug Tools

```gdscript
# Print all tracked objects and their states to console
PersistenceManager.debug_print_all_states()

# Get list of all registered IDs
var all_ids = PersistenceManager.get_all_object_ids()

# Remove a specific object's state
PersistenceManager.remove_object_state("unwanted_id")
```

## Integration with LevelRegion

When using the LevelRegion system, objects will reload when you return to an area. PersistenceManager ensures they restore their correct state:

```gdscript
# In your pickup/door script
func _ready():
    # This runs every time the scene is instantiated
    # (when LevelRegion loads the chunk)

    if PersistenceManager.is_collected(pickup_id):
        # Hide/remove if already collected
        visible = false
    else:
        # Show and enable interaction
        visible = true
```

The LevelRegion system handles scene loading/unloading, while PersistenceManager handles state.

## Best Practices

1. **Always check state in `_ready()`**: Objects may be loaded/unloaded multiple times
2. **Use unique IDs**: Never reuse IDs across different objects
3. **Register early**: Call `register_object()` in `_ready()` if not already registered
4. **Use helpers when possible**: `mark_as_collected()` is cleaner than manual property setting
5. **Save periodically**: Call `save_to_file()` at checkpoints or when player saves game
6. **Validate IDs**: Add an export validation to catch empty IDs in the editor

## Example: Complete Pickup Script

See `scripts/pickup.gd` for a full example implementation that includes:
- Unique ID validation
- State checking on load
- Auto-hiding if collected
- Collection animation
- Integration with dialogue system

## Example: Complete Door Script

See `scripts/persistent_door.gd` for a full example implementation that includes:
- Open/closed state persistence
- Door animation on opening
- Collision disabling when open
- Immediate state restoration on scene load

## Troubleshooting

**Object state not persisting:**
- Verify the object has a unique, non-empty ID
- Check that you're calling the appropriate mark/set methods
- Ensure `register_object()` is called in `_ready()`

**Duplicate ID warning:**
- Each object needs a globally unique ID
- Never reuse IDs across different pickups/doors/objects
- Use descriptive naming: `area_type_item_number`

**State doesn't restore after scene reload:**
- Make sure you check state in `_ready()`, not just `_init()`
- Verify the object is checking `has_object_state()` or `is_collected()`
- Call `debug_print_all_states()` to see what's actually tracked

## Next Steps

1. Try the example pickup scene: `scenes/interactables/pickup_example.tscn`
2. Create your own pickup with a unique ID
3. Test collecting it, switching dimensions, and watching it stay collected
4. Build a persistent door or switch using `persistent_door.gd` as reference
5. Integrate save/load with your game's save system
