# Level Region System

The **LevelRegion** system is a proximity-based level streaming solution designed for creating large, explorable worlds in The Unknown.

## Overview

A LevelRegion is a "chunk" of your level that can hold different sub-scenes for each dimension. It automatically loads and unloads content based on the player's distance, saving memory and improving performance.

## How It Works

1. **Dimension-Specific Content**: Each LevelRegion holds 4 sub-scene references (Normal, Viking, Aztec, Nightmare)
2. **Automatic Scene Swapping**: When dimensions change, the active sub-scene automatically swaps
3. **Proximity Loading**:
   - If player is within `load_distance` (default: 50m), the region loads
   - If player is beyond `unload_distance` (default: 75m), the region unloads
   - This saves memory and improves performance for large levels

## Basic Usage

### 1. Create Your Sub-Scenes

Create 4 separate scenes for each dimension variant of your region:

```
scenes/
└── level_regions/
    └── my_area/
        ├── my_area_normal.tscn
        ├── my_area_viking.tscn
        ├── my_area_aztec.tscn
        └── my_area_nightmare.tscn
```

Each sub-scene can contain anything: meshes, lights, enemies, collectibles, etc.

### 2. Add a LevelRegion to Your Scene

1. In your main scene, add a new Node3D
2. Attach the `level_region.gd` script
3. Position it where you want the chunk to be located
4. In the Inspector, assign your 4 sub-scenes:
   - Normal Scene
   - Viking Scene
   - Aztec Scene
   - Nightmare Scene

### 3. Configure Proximity Settings

- **Load Distance**: How close the player must be to load this region (default: 50m)
- **Unload Distance**: How far the player must be to unload this region (default: 75m)
- **Check Interval**: How often to check distance in seconds (default: 0.5s)

**Important**: `unload_distance` should always be greater than `load_distance` to prevent thrashing (constant loading/unloading).

## Example Setup

See `example_chunks/` for a simple demonstration:
- 4 colored cube scenes (gray, blue, gold, red)
- Each with a floating label
- Ready to be assigned to a LevelRegion

## Advanced Features

### Debug Mode

Enable `debug_mode` in the Inspector to see console messages:
- When the region loads/unloads
- Current distance to player
- Dimension swaps

### Manual Control

The LevelRegion provides public methods for manual control:

```gdscript
# Force load regardless of distance
level_region.force_load()

# Force unload regardless of distance
level_region.force_unload()

# Check if region is currently loaded
if level_region.is_region_loaded():
    print("Region is loaded!")

# Get current distance to player
var distance = level_region.get_distance_to_player()

# Manually set player reference (if player spawns after regions)
level_region.set_player_reference(player_node)
```

### Signals

The LevelRegion emits signals for custom behavior:

```gdscript
# Emitted when region loads (includes dimension index)
level_region.region_loaded.connect(_on_region_loaded)

# Emitted when region unloads
level_region.region_unloaded.connect(_on_region_unloaded)
```

## Performance Tips

1. **Optimal Load Distance**:
   - Too small: Visible pop-in as player moves
   - Too large: Too many regions loaded at once
   - Sweet spot: 50-100m depending on your level density

2. **Check Interval**:
   - Checking every frame is wasteful
   - 0.5s (default) is a good balance
   - Increase for less frequent checks (saves CPU)

3. **Hysteresis**:
   - Always set `unload_distance` > `load_distance`
   - Recommended: 25-50m gap between them
   - Prevents flickering when player hovers at boundary

## Level Design Workflow

### Approach 1: Hand-Placed Chunks
1. Design your level in separate "chunk" scenes
2. Place LevelRegion nodes in your main scene
3. Assign chunk scenes to each region
4. Test by moving the player around

### Approach 2: Grid-Based System
1. Create a script that spawns LevelRegions in a grid pattern
2. Assign chunk scenes programmatically based on coordinates
3. Useful for procedural generation or very large worlds

### Approach 3: Hybrid
1. Hand-place LevelRegions for important areas
2. Use grid generation for filler areas
3. Mix unique content with repeated patterns

## Example: Creating a Simple Test Region

```gdscript
# In your main scene or level manager script

func create_test_region():
    # Create a new LevelRegion
    var region = LevelRegion.new()
    region.position = Vector3(0, 0, -50)  # 50m away from origin

    # Assign scenes
    region.normal_scene = preload("res://scenes/level_regions/example_chunks/normal_chunk.tscn")
    region.viking_scene = preload("res://scenes/level_regions/example_chunks/viking_chunk.tscn")
    region.aztec_scene = preload("res://scenes/level_regions/example_chunks/aztec_chunk.tscn")
    region.nightmare_scene = preload("res://scenes/level_regions/example_chunks/nightmare_chunk.tscn")

    # Configure
    region.load_distance = 30.0
    region.unload_distance = 50.0
    region.debug_mode = true

    # Add to scene
    add_child(region)
```

## Troubleshooting

**Region never loads**:
- Check that player is in the "player" group
- Verify load_distance is large enough
- Enable debug_mode to see distance checks

**Constant loading/unloading**:
- Increase gap between load_distance and unload_distance
- Check that player isn't spawning right at the boundary

**Wrong scene shows up**:
- Verify all 4 scenes are assigned correctly
- Check that dimension manager is working
- Enable debug_mode to see dimension swaps

**Performance issues**:
- Increase check_interval (check less frequently)
- Reduce number of active regions
- Optimize your sub-scenes (fewer polygons, simpler materials)

## Next Steps

1. Create your first test region using the example chunks
2. Walk around and watch it load/unload
3. Try switching dimensions while standing inside
4. Design your first custom chunk variants
5. Build out your level with multiple regions!
