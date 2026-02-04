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
- **Raycast-based interaction system** - look at objects and press E to interact
- **Dialogue system** for displaying text from interactable objects
- DimensionObject base class for objects that change appearance and collision based on dimension
- DimensionEnvironment system for instant sky and ambient lighting changes per dimension
- Animated transition overlay with color flash effect when switching dimensions
- Dimension-specific collision (walls that only exist in certain dimensions)
- Test scene demonstrating:
  - A statue that changes color based on the active dimension
  - A blue wall that only has collision in the Viking dimension (press 2) - you must switch to another dimension to pass through it
  - An interactable pedestal - look at it and press E to read dialogue
  - Distinct sky colors and ambient lighting for each dimension:
    - **Normal (1)**: Light blue sky, neutral lighting
    - **Viking (2)**: Deep blue sky, cool blue ambient
    - **Aztec (3)**: Golden/orange sky, warm golden ambient
    - **Nightmare (4)**: Dark red sky, dim red ambient

## Code Style

This project uses **4 spaces** for indentation (no tabs). The `.editorconfig` file ensures consistent formatting across editors.

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
