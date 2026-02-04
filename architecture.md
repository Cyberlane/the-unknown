* Engine: Godot 4.x (GDScript)
* Perspective: First-Person 3D
* Core Mechanic: Dimension Swapping (Normal, Viking, Aztec, Nightmare)
* Naming Convention: PascalCase for Scenes, snake_case for scripts
* Code Style: 4 spaces for indentation (enforced via .editorconfig)
* Global Singleton: DimensionManager (scripts/autoload/dimension_manager.gd) ✓

## Core Systems

### Interaction System
- Raycast-based interaction from player camera
- Interactable base class for objects that can be examined/used
- Press E to interact with objects in view (3m range by default)
- Automatic interaction prompt display when looking at interactables
- Dialogue system for text-based interactions
- Collision layer 2 used for interactable objects

## Implemented Systems

### DimensionManager (Autoload)
- Global singleton for managing dimension state
- Emits `dimension_changed` signal when dimensions switch
- Enum: NORMAL, VIKING, AZTEC, NIGHTMARE
- Method: `switch_to(dimension_index: int)`

### ChoiceManager (Autoload)
- Global singleton for tracking player choices and alignment
- Tracks `alignment_score` (-100 to 100): darker vs lighter choices
- Tracks dimension-specific trust values (0 to 100):
  - `viking_trust`: Trust with Viking spirits
  - `aztec_trust`: Trust with Aztec civilization
  - `nightmare_trust`: Trust with nightmare entities
- Methods: `modify_alignment()`, `modify_viking_trust()`, etc.
- Records all choices with timestamps and metadata
- Emits signals on value changes
- Helpers: `get_alignment_type()`, `get_trust_level()`
- Save/load support ready for implementation

### DimensionObject (Base Class)
- @tool script - works in both editor and runtime
- Extends Node3D
- Exports 4 mesh references (one per dimension)
- Exports 4 collision shape references (one per dimension)
- **Editor Preview**: "Preview Dimension" dropdown in Inspector
  - Change dimension preview in editor without running game
  - Meshes swap visibility instantly in viewport
- Runtime: Automatically shows/hides meshes based on active dimension
- Runtime: Automatically enables/disables collision shapes based on active dimension
- Connects to DimensionManager's signal on _ready() (runtime only)
- Enables dimension-specific geometry and physics (e.g., walls that only exist in certain dimensions)

### DimensionTrigger (Area3D)
- @tool script - shows debug visualization in editor
- Extends Area3D
- Only fires `dimension_triggered(body)` signal in specific dimension
- Configurable dimension: NORMAL, VIKING, AZTEC, NIGHTMARE, or ANY
- Optional one-shot mode (trigger only once)
- Debug message printed to console when triggered
- Semi-transparent debug mesh in editor (color-coded by dimension)
- Perfect for dimension-specific puzzles, secrets, and events

### AtmosphereManager (Professional Manager)
- Extends Node
- **Unified system** managing both Environment and DirectionalLight3D
- Manages 4 Environment resources (one per dimension)
- Manages dimension-specific light settings (color and energy per dimension)
- **Smooth interpolated transitions** using Tween system (0.6s default)
- **Coordinates with shader overlay** - triggers transition effect to peak at midpoint (0.3s)
- Transitions multiple properties simultaneously:
  - Sky colors (top, horizon, ground)
  - Ambient light color and energy
  - Fog density, color, and energy
  - Exposure/tonemap values
  - Directional light color
  - Directional light energy
- Configurable transition toggles for sky, fog, and exposure
- Each dimension has unique atmosphere and lighting:
  - Normal: Light blue sky, neutral ambient, light fog, 1.0 exposure, warm white light (1.0 energy)
  - Viking: Deep blue sky, cool blue ambient, thick fog, 0.85 exposure, cool blue light (0.85 energy - darker)
  - Aztec: Golden/orange sky, warm ambient, moderate fog, 1.15 exposure, warm golden light (1.2 energy - brighter)
  - Nightmare: Dark red sky, dim red ambient, heavy fog, 0.7 exposure, dim red light (0.6 energy - darkest)
- Uses cubic ease in/out for smooth, professional feel
- All transitions happen in parallel for synchronized atmosphere changes

### DimensionTransitionOverlay (CanvasLayer)
- Extends CanvasLayer
- Uses enhanced dimension_transition.gdshader with:
  - Screen-space color flash effect
  - **Pixelation effect** (screen breaks into pixels)
  - **Chromatic aberration** (RGB channel separation)
  - **Glitch spike** at peak of transition
- Animates shader 'progress' parameter with Tween (0 → 1 → 0)
- Glitch intensity spikes at transition peak (when dimensions actually swap)
- Each dimension has a signature color for the transition flash
- Configurable glitch settings: intensity, duration, pixelation, aberration
- Smooth cubic ease in/out animation (default 0.3s duration)
- **Supports custom duration** via `play_transition_with_duration()` for external coordination
- AtmosphereManager triggers this to peak at midpoint, hiding mesh-swapping pops

### NightmareVoices (Node)
- Extends Node
- Listens to dimension_changed signal
- Displays random voice lines when entering Nightmare dimension
- Configurable list of creepy/atmospheric strings
- Auto-dismisses dialogue after configurable time (default 4s)
- Option to show on every entry or only first time
- Uses existing DialogueUI for display

### Player Controller
- First-person CharacterBody3D with mouse look
- WASD movement, Space to jump
- Keys 1-4 trigger dimension switching
- **E key for interactions**
- ESC toggles mouse capture
- RayCast3D from camera for detecting interactables (3m range)
- AudioStreamPlayer for dimension switch sound effects
- Dimension-specific pitch variations:
  - Normal: 1.0x (base pitch)
  - Viking: 0.85x (lower, heavier)
  - Aztec: 1.2x (higher, lighter)
  - Nightmare: 0.7x (lowest, ominous)

### DimensionAmbientAudio (Node)
- Manages 4 simultaneous ambient audio loops (one per dimension)
- All loops play constantly at -80db (silent)
- Cross-fades active dimension to 0db over 2 seconds
- Cross-fades inactive dimensions back to -80db
- Keeps all loops synchronized (no phase issues)
- Smooth Tween-based volume transitions
- Cubic ease in/out for natural feel
- Routes to "Ambient" audio bus
- Configurable crossfade duration and volume levels

### LevelRegion (Proximity-Based Level Streaming)
- Extends Node3D
- **Level chunk/region system** for building large explorable worlds
- Holds 4 PackedScene references (one per dimension)
- **Automatic scene swapping** when dimensions change
- **Proximity-based loading/unloading** based on player distance
- Configurable load_distance (default: 50m) and unload_distance (default: 75m)
- Hysteresis prevents thrashing (unload_distance > load_distance)
- Periodic distance checking (default: 0.5s interval)
- Finds player automatically via "player" group
- Public API for manual control:
  - `force_load()` / `force_unload()` - manual override
  - `is_region_loaded()` - check load state
  - `get_distance_to_player()` - current distance
  - `set_player_reference()` - manual player assignment
- Signals: `region_loaded(dimension)`, `region_unloaded()`
- Debug mode with console messages and visual indicators
- Foundation for level design workflow:
  - Hand-placed chunks for unique areas
  - Grid-based generation for large worlds
  - Hybrid approach mixing both techniques
- Memory efficient - only loaded regions consume memory
- Example chunks provided in `scenes/level_regions/example_chunks/`

## Scene Structure

### test_scene.tscn
- Main test/demo scene
- Contains: Floor, DirectionalLight3D, Player, Statue, VikingWall, EnvironmentManager
- Statue uses DimensionObject with 4 colored cubes (gray, blue, gold, red)
- VikingWall demonstrates dimension-specific collision (only solid in Viking dimension)
- EnvironmentManager with 4 WorldEnvironment nodes for instant sky/lighting changes
