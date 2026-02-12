# Editor Mode Setup Guide - Step 1

This guide will walk you through setting up the editor mode foundation in Godot.

## Files Created

✅ **Scripts:**
- `scripts/autoloads/editor_mode.gd` - Editor state manager
- `scenes/editor/editor_camera.gd` - Free-fly camera for editor
- `scenes/editor/editor_grid.gd` - Visual grid system
- `scenes/editor/editor_ui.gd` - Editor UI overlay

✅ **Configuration:**
- `project.godot` - Added EditorMode autoload and toggle_editor input (F1)
- `scenes/player/first_person_controller.gd` - Updated to work with editor mode

## Scene Setup Instructions

Follow these steps in the Godot editor to create the required scenes:

---

### 1. Create EditorCamera Scene

1. **Create new scene:**
   - Click **Scene → New Scene**
   - Select **Camera3D** as root node
   - Rename it to `EditorCamera`

2. **Configure the camera:**
   - In Inspector, set properties:
     - Position: `(0, 5, 10)` (starting position)
     - Current: `false` (will be enabled when editor activates)
     - FOV: `75`

3. **Attach script:**
   - Click the script icon next to EditorCamera
   - Select **Load** and choose `res://scenes/editor/editor_camera.gd`

4. **Save scene:**
   - **Scene → Save Scene As**
   - Save to: `res://scenes/editor/editor_camera.tscn`

---

### 2. Create EditorGrid Scene

1. **Create new scene:**
   - Click **Scene → New Scene**
   - Select **MeshInstance3D** as root node
   - Rename it to `EditorGrid`

2. **Configure the grid:**
   - In Inspector, set Position: `(0, 0, 0)`

3. **Attach script:**
   - Click the script icon
   - Select **Load** and choose `res://scenes/editor/editor_grid.gd`

4. **Configure script properties in Inspector:**
   - Grid Size: `1.0`
   - Grid Extent: `50`
   - Grid Color: `RGBA(0.5, 0.5, 0.5, 0.3)`
   - Center Line Color: `RGBA(0.8, 0.8, 0.8, 0.5)`

5. **Save scene:**
   - Save to: `res://scenes/editor/editor_grid.tscn`

---

### 3. Create EditorUI Scene

1. **Create new scene:**
   - Click **Scene → New Scene**
   - Select **CanvasLayer** as root node
   - Rename it to `EditorUI`

2. **Create toolbar:**
   - Right-click EditorUI → **Add Child Node**
   - Add **PanelContainer**, name it `Toolbar`
   - In Inspector:
     - Anchors Preset: **Top Wide**
     - Offset Top: `0`
     - Offset Bottom: `50`

   - Right-click Toolbar → **Add Child Node** → **MarginContainer**
     - In Inspector, under **Theme Overrides → Constants:**
       - Margin Left: `10`
       - Margin Right: `10`
       - Margin Top: `5`
       - Margin Bottom: `5`

   - Right-click MarginContainer → **Add Child Node** → **HBoxContainer**
   - Right-click HBoxContainer → **Add Child Node** → **Label**, name it `ModeLabel`
     - Text: `EDITOR MODE`
     - Theme Overrides → Font Size: `20`

3. **Create status bar:**
   - Right-click EditorUI → **Add Child Node**
   - Add **PanelContainer**, name it `StatusBar`
   - In Inspector:
     - Anchors Preset: **Bottom Wide**
     - Offset Top: `-40`
     - Offset Bottom: `0`

   - Right-click StatusBar → **Add Child Node** → **MarginContainer**
     - Margin Left/Right/Top/Bottom: `10`, `10`, `5`, `5`

   - Right-click MarginContainer → **Add Child Node** → **HBoxContainer**

   - Right-click HBoxContainer → **Add Child Node** → **Label**, name it `CameraPosLabel`
     - Text: `Camera: 0, 0, 0`

   - Right-click HBoxContainer → **Add Child Node** → **Control** (as spacer)
     - Size Flags Horizontal: **Expand**

   - Right-click HBoxContainer → **Add Child Node** → **Label**, name it `GridSnapLabel`
     - Text: `Grid Snap: ON`

4. **Attach script to EditorUI:**
   - Select the root EditorUI node
   - Attach script: `res://scenes/editor/editor_ui.gd`

5. **Save scene:**
   - Save to: `res://scenes/editor/editor_ui.tscn`

---

### 4. Create EditorManager Scene (Combines Everything)

1. **Create new scene:**
   - Click **Scene → New Scene**
   - Select **Node3D** as root node
   - Rename it to `EditorManager`

2. **Add editor components:**
   - Right-click EditorManager → **Instantiate Child Scene**
   - Add `res://scenes/editor/editor_camera.tscn`

   - Right-click EditorManager → **Instantiate Child Scene**
   - Add `res://scenes/editor/editor_grid.tscn`

   - Right-click EditorManager → **Instantiate Child Scene**
   - Add `res://scenes/editor/editor_ui.tscn`

3. **Save scene:**
   - Save to: `res://scenes/editor/editor_manager.tscn`

---

### 5. Add EditorManager to Test Scene

1. **Open `res://scenes/test_scene.tscn`**

2. **Instance EditorManager:**
   - Right-click the root `TestScene` node
   - **Instantiate Child Scene**
   - Select `res://scenes/editor/editor_manager.tscn`
   - Position it at top of scene tree (for visibility)

3. **Save the scene**

---

## Testing the Editor

1. **Run the test scene:**
   - Press **F5** or click the play button
   - The game should start in normal play mode

2. **Toggle editor mode:**
   - Press **F1** to enable editor mode
   - You should see:
     - Game pauses
     - Player controls disabled
     - Editor UI appears (green "EDITOR MODE" text at top)
     - Status bar at bottom showing camera position
     - Grid on ground (if visible)

3. **Test editor camera:**
   - Hold **Right Mouse Button** and move mouse to look around
   - **WASD** to move horizontally
   - **Q** to move down
   - **E** to move up
   - **Shift** while moving = faster
   - **Ctrl** while moving = slower
   - **G** key should toggle grid visibility (feature for later)

4. **Toggle back to play mode:**
   - Press **F1** again
   - Game should resume
   - Player controls should work again
   - Editor UI should disappear

---

## Troubleshooting

### Editor mode doesn't activate
- Check the console for errors
- Verify EditorMode autoload is registered in Project Settings → Autoload
- Verify F1 input action exists in Project Settings → Input Map

### Camera doesn't move
- Make sure you're holding Right Mouse Button while moving the mouse
- Check that EditorMode.editor_active is true (add debug print)
- Verify editor_camera is not null in EditorMode

### Grid doesn't appear
- Check that EditorGrid scene is instantiated in EditorManager
- Verify grid_visible is true in EditorMode
- Try increasing grid opacity in editor_grid.gd

### Player still moves in editor mode
- Verify player controller registered with EditorMode in _ready()
- Check that EditorMode.player_controller is not null
- Verify process_mode is being set correctly

### UI doesn't show
- Check that EditorUI is visible when editor is enabled
- Verify CanvasLayer layer is not behind other UI
- Check node paths in editor_ui.gd match your scene structure

---

## Next Steps

Once Step 1 is complete and working:

✅ You should be able to:
- Toggle editor mode with F1
- Fly around with editor camera
- See the grid on the ground
- View editor UI showing camera position and status
- Toggle back to play mode seamlessly

**Ready for Step 2:** Block Palette & Placement System

---

## Keybinds Summary (Step 1)

| Key | Action |
|-----|--------|
| **F1** | Toggle editor mode on/off |
| **Right Mouse + Move** | Look around (editor camera) |
| **WASD** | Move horizontally (editor camera) |
| **Q** | Move down (editor camera) |
| **E** | Move up (editor camera) |
| **Shift** | Move faster (editor camera) |
| **Ctrl** | Move slower (editor camera) |
| **G** | Toggle grid visibility (planned) |
