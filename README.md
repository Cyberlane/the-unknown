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
- **ESC**: Toggle mouse capture
- **1**: Switch to Normal dimension (gray)
- **2**: Switch to Viking dimension (blue)
- **3**: Switch to Aztec dimension (gold)
- **4**: Switch to Nightmare dimension (red)

## Features

- First-person character controller with mouse look
- Global dimension management system
- DimensionObject base class for objects that change appearance and collision based on dimension
- DimensionEnvironment system for instant sky and ambient lighting changes per dimension
- Dimension-specific collision (walls that only exist in certain dimensions)
- Test scene demonstrating:
  - A statue that changes color based on the active dimension
  - A blue wall that only has collision in the Viking dimension (press 2) - you must switch to another dimension to pass through it
  - Distinct sky colors and ambient lighting for each dimension:
    - **Normal (1)**: Light blue sky, neutral lighting
    - **Viking (2)**: Deep blue sky, cool blue ambient
    - **Aztec (3)**: Golden/orange sky, warm golden ambient
    - **Nightmare (4)**: Dark red sky, dim red ambient

## Code Style

This project uses **4 spaces** for indentation (no tabs). The `.editorconfig` file ensures consistent formatting across editors.

## Getting Started

1. Open the project in Godot 4.5
2. Press F5 to run the test scene
3. Use number keys 1-4 to switch between dimensions and watch the statue change colors
