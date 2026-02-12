# Stage 1 Setup Guide

This guide will help you set up the core foundation files for The Unknown.

## Files Created

### 1. EventBus Autoload (`scripts/autoloads/event_bus.gd`)
- Central signal hub for decoupled communication
- Contains all major game event signals

### 2. First Person Controller (`scenes/player/first_person_controller.gd`)
- Complete WASD movement system
- Mouse look with vertical clamping
- Sprint and crouch mechanics
- Head bob animation
- Debug info output

### 3. Interaction System (`scripts/components/interaction_raycast.gd`)
- Raycast-based object detection
- Automatic interaction prompt display
- EventBus integration

### 4. Simple Interactable (`scripts/components/simple_interactable.gd`)
- Base class for interactable objects
- One-time use option
- Custom interaction prompts

### 5. Debug Overlay (`scenes/ui/debug_overlay.gd`)
- FPS counter
- Player position and velocity
- State information (crouching, sprinting, etc.)

## Godot Editor Setup

### Step 1: Configure EventBus Autoload

1. Open **Project → Project Settings → Autoload**
2. Click the folder icon and navigate to `scripts/autoloads/event_bus.gd`
3. Set the Node Name to `EventBus`
4. Click **Add**
5. Ensure "Enable" checkbox is checked

### Step 2: Configure Input Map

Follow the instructions in `docs/INPUT_MAP_SETUP.md` to add all required input actions.

### Step 3: Create First Person Controller Scene

1. Create a new scene in Godot
2. Add a **CharacterBody3D** as the root node
3. Rename it to `FirstPersonController`
4. Attach the script `scenes/player/first_person_controller.gd`
5. Add a **Camera3D** as a child of CharacterBody3D
   - Set Camera3D position to `(0, 1.7, 0)` (eye height)
6. Add a **CollisionShape3D** as a child of CharacterBody3D
   - Add a **CapsuleShape3D** to the shape property
   - Set Capsule Height to `2.0`
   - Set Capsule Radius to `0.4`
7. Add an **InteractionRaycast** (RayCast3D) as a child of Camera3D
   - Attach the script `scripts/components/interaction_raycast.gd`
   - Set enabled to `true`
8. Add the CharacterBody3D to the "player" group:
   - Select the root node
   - Go to the Node tab (next to Inspector)
   - Under Groups, add "player"
9. Save the scene as `scenes/player/first_person_controller.tscn`

**Scene Tree Structure:**
```
FirstPersonController (CharacterBody3D) [script: first_person_controller.gd]
├─ Camera3D
│  └─ InteractionRaycast (RayCast3D) [script: interaction_raycast.gd]
└─ CollisionShape3D (CapsuleShape3D)
```

### Step 4: Create Debug Overlay Scene

1. Create a new scene
2. Add a **CanvasLayer** as root
3. Rename it to `DebugOverlay`
4. Attach the script `scenes/ui/debug_overlay.gd`
5. Add a **MarginContainer** as child
   - Set Anchors Preset to "Top Left"
   - Set margins: Left: 10, Top: 10
6. Add a **VBoxContainer** as child of MarginContainer
7. Add a **Label** as child of VBoxContainer, name it `FPSLabel`
   - Set theme color override "Font Color" to green `#00ff00`
8. Add another **Label** as child of VBoxContainer, name it `DebugLabel`
   - Set theme color override "Font Color" to white `#ffffff`
9. Save as `scenes/ui/debug_overlay.tscn`

**Scene Tree Structure:**
```
DebugOverlay (CanvasLayer) [script: debug_overlay.gd]
└─ MarginContainer
   └─ VBoxContainer
      ├─ FPSLabel (Label)
      └─ DebugLabel (Label)
```

### Step 5: Create Test Scene

1. Create a new 3D scene
2. Add a **Node3D** as root, name it `TestLevel`
3. Add a **DirectionalLight3D** for lighting
   - Set rotation to approximately `(-45, -45, 0)` degrees
4. Add a **WorldEnvironment**
   - Create a new Environment
   - Set Background Mode to "Sky"
   - Create a new Sky resource with a ProceduralSkyMaterial
5. Add some **CSGBox3D** nodes to create floors and walls:
   - Floor: Size `(20, 0.5, 20)`, Position `(0, -0.25, 0)`
   - Walls around the perimeter
6. Instance your `FirstPersonController` scene (Ctrl+Shift+A or Scene → Instantiate Child Scene)
   - Set position to `(0, 2, 0)` (above the floor)
7. Instance your `DebugOverlay` scene
8. Save as `scenes/test_level.tscn`

### Step 6: Create Example Interactable

1. In the test scene, add a **StaticBody3D**
2. Rename it to `TestCube`
3. Attach the script `scripts/components/simple_interactable.gd`
4. Add a **MeshInstance3D** as child
   - Set Mesh to new BoxMesh
5. Add a **CollisionShape3D** as child
   - Set Shape to new BoxShape3D
6. Position it somewhere in front of the player spawn
7. In the Inspector, set the interaction prompt to "Press [E] to examine cube"

## Testing

1. Set `scenes/test_level.tscn` as the main scene (F6 or Play Scene)
2. You should be able to:
   - Move with WASD
   - Look around with mouse
   - Sprint with Shift
   - Crouch with Ctrl
   - See head bob while walking
   - See FPS and position in debug overlay (press F3 to toggle)
   - Look at the test cube to see interaction prompt
   - Press E to interact with the cube

## Troubleshooting

### Mouse is not captured
- Make sure you're in play mode (not paused)
- Press Escape once to release, then click the game window to recapture

### Camera is not moving
- Check that the Camera3D is properly parented to the CharacterBody3D
- Verify mouse sensitivity is not set to 0

### Can't see anything
- Make sure DirectionalLight3D is added to the scene
- Check that WorldEnvironment is configured

### No interaction prompt showing
- Verify the interactable StaticBody3D has collision layer 2 enabled
- Check that InteractionRaycast collision mask is set to layer 2
- Make sure the interactable is within 3 units of the player

### Debug overlay not showing
- Press F3 to toggle it
- Check that DebugOverlay is instantiated in the scene
- Verify the player is in the "player" group

## Next Steps

Once Stage 1 is complete and tested, you can move on to:
- **Stage 2**: Level Editor (Creative Mode)
- Create a basic test environment with CSG shapes
- Add placeholder textures from Kenney Prototype Textures pack
- Add footstep audio placeholders

## Old Prototype Files

The following files from the original prototype can be archived or removed:
- `scripts/interactable.gd` (replaced by `simple_interactable.gd`)
- `scripts/ui/dialogue_ui.gd` (will be reimplemented in Stage 7)
- `scripts/ui/interaction_ui.gd` (replaced by debug_overlay + EventBus)
- `scripts/nightmare_voices.gd` (will be reimplemented in Stage 4)
- `scripts/dimension_object.gd` (will be reimplemented in Stage 3)
- `scripts/dimension_trigger.gd` (will be reimplemented in Stage 3)
- `scripts/test_trigger_handler.gd` (test code)
- `scripts/autoload/choice_manager.gd` (will be reimplemented in Stage 7)
- `scripts/viking_choice_example.gd` (example code)
- `scripts/dimension_environment.gd` (will be reimplemented in Stage 3)
- `scripts/dimension_ambient_audio.gd` (will be reimplemented in Stage 3)
- `scripts/atmosphere_manager.gd` (will be reimplemented in Stage 3)
- `scripts/dimension_transition_overlay.gd` (will be reimplemented in Stage 3)
- `scripts/level_region.gd` (will be reimplemented in Stage 9)
- `scenes/player/player.gd` (replaced by `first_person_controller.gd`)
- `scripts/autoload/persistence_manager.gd` (will be reimplemented in Stage 9)
- `scripts/pickup.gd` (will be reimplemented in Stage 8)
- `scripts/persistent_door.gd` (will be reimplemented in Stage 9)
- `scripts/dimension_gate.gd` (will be reimplemented in Stage 3)
- `scripts/autoload/dimension_manager.gd` (will be reimplemented in Stage 3)
- `scripts/persistent_box.gd` (will be reimplemented in Stage 9)
- `scripts/voice_trigger.gd` (will be reimplemented in Stage 4)

Consider moving these to a `_prototype_backup/` folder for reference.
