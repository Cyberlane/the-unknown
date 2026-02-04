# The Unknown

A Godot 4.5 first-person game with dimension-switching mechanics.

## Project Structure

```
the-unknown/
├── scenes/
│   ├── player/
│   │   ├── player.gd           # First-person controller script
│   │   └── player.tscn         # Player scene
│   └── test_scene.tscn         # Test scene with floor and statue
├── scripts/
│   ├── autoload/
│   │   └── dimension_manager.gd  # Global dimension manager (autoload)
│   └── dimension_object.gd       # Base class for dimension-switching objects
└── project.godot
```

## Controls

- **WASD**: Move around
- **Mouse**: Look around
- **Space**: Jump
- **E**: Interact with objects
- **ESC**: Toggle mouse capture / Close dialogue
- **1**: Switch to Normal dimension (gray)
- **2**: Switch to Viking dimension (blue)
- **3**: Switch to Aztec dimension (gold)
- **4**: Switch to Nightmare dimension (red)

## Features

- First-person character controller with mouse look
- Global dimension management system
- **Choice & alignment system** - track player decisions and build trust with different dimensions
- **PersistenceManager** - global state tracking for pickups, doors, switches that persists across dimensions and scene reloads
- **Raycast-based interaction system** - look at objects and press E to interact
- **Dialogue system** for displaying text from interactable objects
- **Nightmare dimension voice lines** - random creepy messages appear when entering the Nightmare dimension
- **DimensionTrigger system** - Area3D triggers that only activate in specific dimensions
- **DimensionGate system** - portals and lock zones for controlling dimension swapping:
  - **Passive mode**: Prevents dimension switching while inside (lock zones for puzzles/bosses)
  - **Active mode**: Forces player to specific dimension on entry (portals between dimension areas)
- DimensionObject base class for objects that change appearance and collision based on dimension
- **LevelRegion system** - proximity-based level streaming with automatic loading/unloading based on player distance
- **Professional AtmosphereManager** - coordinates smooth 0.6s transitions for sky, fog, exposure, and directional lighting
- Animated transition overlay with color flash, pixelation, and chromatic aberration glitch effects (peaks at midpoint to hide mesh swaps)
- **Cross-fading ambient audio system** - 4 loops play simultaneously, active dimension fades in
- Dimension-specific collision (walls that only exist in certain dimensions)
- Test scene demonstrating:
  - A statue that changes color based on the active dimension
  - A blue wall that only has collision in the Viking dimension (press 2) - you must switch to another dimension to pass through it
  - An interactable pedestal - look at it and press E to read dialogue
  - A Viking shrine - interact to gain Viking trust (tracks your choices!)
  - Random voice lines appear when entering the Nightmare dimension
  - A secret Aztec trigger - only activates when you're in the Aztec dimension!
  - Distinct sky colors and ambient lighting for each dimension:
    - **Normal (1)**: Light blue sky, neutral lighting
    - **Viking (2)**: Deep blue sky, cool blue ambient
    - **Aztec (3)**: Golden/orange sky, warm golden ambient
    - **Nightmare (4)**: Dark red sky, dim red ambient + creepy voice lines

## Code Style

This project uses **4 spaces** for indentation (no tabs). The `.editorconfig` file ensures consistent formatting across editors.

## Editor Workflow Tips

**Previewing Dimensions**: DimensionObject is a @tool script. When editing objects with dimension variants:
1. Select a DimensionObject node in the scene tree
2. In the Inspector, find "Preview Dimension" under "Editor Preview"
3. Change the dropdown (Normal/Viking/Aztec/Nightmare)
4. The meshes will instantly swap in the viewport without running the game!

## Getting Started

1. Open the project in Godot 4.5
2. **(Optional)** Add a whoosh sound effect:
   - Place an audio file (`.ogg` or `.wav`) in `audio/sfx/`
   - Open `scenes/player/player.tscn`
   - Select the Player node
   - Set the "Dimension Switch Sound" property to your audio file
   - See `audio/README.md` for where to find free sound effects
3. Press F5 to run the test scene
4. Use number keys 1-4 to switch between dimensions and watch the statue change colors
