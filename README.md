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
- DimensionObject base class for objects that change appearance based on dimension
- Test scene with a statue that changes color based on the active dimension

## Code Style

This project uses **4 spaces** for indentation (no tabs). The `.editorconfig` file ensures consistent formatting across editors.

## Getting Started

1. Open the project in Godot 4.5
2. Press F5 to run the test scene
3. Use number keys 1-4 to switch between dimensions and watch the statue change colors
