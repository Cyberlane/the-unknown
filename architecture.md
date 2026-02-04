* Engine: Godot 4.x (GDScript)
* Perspective: First-Person 3D
* Core Mechanic: Dimension Swapping (Normal, Viking, Aztec, Nightmare)
* Naming Convention: PascalCase for Scenes, snake_case for scripts
* Code Style: 4 spaces for indentation (enforced via .editorconfig)
* Global Singleton: DimensionManager (scripts/autoload/dimension_manager.gd) ✓

## Implemented Systems

### DimensionManager (Autoload)
- Global singleton for managing dimension state
- Emits `dimension_changed` signal when dimensions switch
- Enum: NORMAL, VIKING, AZTEC, NIGHTMARE
- Method: `switch_to(dimension_index: int)`

### DimensionObject (Base Class)
- Extends Node3D
- Exports 4 mesh references (one per dimension)
- Exports 4 collision shape references (one per dimension)
- Automatically shows/hides meshes based on active dimension
- Automatically enables/disables collision shapes based on active dimension
- Connects to DimensionManager's signal on _ready()
- Enables dimension-specific geometry and physics (e.g., walls that only exist in certain dimensions)

### Player Controller
- First-person CharacterBody3D with mouse look
- WASD movement, Space to jump
- Keys 1-4 trigger dimension switching
- ESC toggles mouse capture

## Scene Structure

### test_scene.tscn
- Main test/demo scene
- Contains: Floor, DirectionalLight3D, Player, Statue, VikingWall
- Statue uses DimensionObject with 4 colored cubes (gray, blue, gold, red)
- VikingWall demonstrates dimension-specific collision (only solid in Viking dimension)
