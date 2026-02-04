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

### DimensionEnvironment (Manager)
- Extends Node
- Manages 4 WorldEnvironment nodes (one per dimension)
- Instantly switches active environment when dimension changes
- Each dimension has unique sky colors and ambient lighting:
  - Normal: Light blue sky, neutral white ambient (0.5 energy)
  - Viking: Deep blue sky, cool blue ambient (0.6 energy)
  - Aztec: Golden/orange sky, warm golden ambient (0.7 energy)
  - Nightmare: Dark red sky, dim red ambient (0.4 energy)

### DimensionTransitionOverlay (CanvasLayer)
- Extends CanvasLayer
- Uses dimension_transition.gdshader for screen-space flash effect
- Animates shader 'progress' parameter with Tween (0 → 1 → 0)
- Each dimension has a signature color for the transition flash
- Triggered automatically when dimension changes
- Smooth cubic ease in/out animation (default 0.3s duration)

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

## Scene Structure

### test_scene.tscn
- Main test/demo scene
- Contains: Floor, DirectionalLight3D, Player, Statue, VikingWall, EnvironmentManager
- Statue uses DimensionObject with 4 colored cubes (gray, blue, gold, red)
- VikingWall demonstrates dimension-specific collision (only solid in Viking dimension)
- EnvironmentManager with 4 WorldEnvironment nodes for instant sky/lighting changes
