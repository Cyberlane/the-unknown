# Editor Mode Setup Guide - Step 2

## Block Palette & Placement System

This guide walks you through setting up the block placement system for the level editor.

---

## Files Created

✅ **Scripts:**
- `scripts/resources/block_resource.gd` - Block definition resource
- `scenes/editor/placeable_block.gd` - Individual placed block instance
- `scenes/editor/block_palette_manager.gd` - Block library manager
- `scenes/editor/block_placer.gd` - Block placement/deletion system
- `scenes/editor/editor_ui.gd` - Updated with block selection display

---

## Scene Setup Instructions

### 1. Create PlaceableBlock Scene

This is the base scene for all blocks that get placed in the editor.

1. **Create new scene:**
   - Click **Scene → New Scene**
   - Select **StaticBody3D** as root node
   - Rename it to `PlaceableBlock`

2. **Add child nodes:**
   - Right-click PlaceableBlock → **Add Child Node** → **MeshInstance3D**
   - Right-click PlaceableBlock → **Add Child Node** → **CollisionShape3D**

3. **Configure PlaceableBlock:**
   - Select PlaceableBlock (root)
   - In Inspector:
     - Collision Layer: `1` (Layer 1)
     - Collision Mask: `0` (Doesn't collide with anything)

4. **Attach script:**
   - Select PlaceableBlock (root)
   - Click script icon → **Load**
   - Choose `res://scenes/editor/placeable_block.gd`

5. **Save scene:**
   - **Scene → Save Scene As**
   - Save to: `res://scenes/editor/placeable_block.tscn`

---

### 2. Update EditorManager Scene

Add the block system components to your existing EditorManager.

1. **Open `res://scenes/editor/editor_manager.tscn`**

2. **Add BlockPaletteManager:**
   - Right-click EditorManager → **Add Child Node** → **Node**
   - Rename it to `BlockPaletteManager`
   - Attach script: `res://scenes/editor/block_palette_manager.gd`

3. **Add BlockPlacer:**
   - Right-click EditorManager → **Add Child Node** → **Node**
   - Rename it to `BlockPlacer`
   - Attach script: `res://scenes/editor/block_placer.gd`

4. **Save the scene**

---

### 3. Update EditorUI Scene

Add the block selection label to the status bar.

1. **Open `res://scenes/editor/editor_ui.tscn`**

2. **Add block selection label:**
   - Navigate to: `StatusBar → MarginContainer → HBoxContainer`
   - Right-click HBoxContainer → **Add Child Node** → **Label**
   - Name it: `BlockSelectionLabel`
   - In Inspector:
     - Text: `Block: Wall [0°]`
     - Theme Overrides → Font Size: `14`

3. **Adjust layout (optional):**
   - You may want to add a **Control** node as a spacer between labels
   - Or adjust the HBoxContainer separation

4. **Save the scene**

---

### 4. Connect Block Placer to Block Palette

We need to connect these systems via script. Create a simple connector script:

1. **Open `res://scenes/editor/editor_manager.tscn`**

2. **Attach a script to EditorManager root:**
   - Select EditorManager (root node)
   - Click **Attach Script** (if not already attached)
   - Create new script: `res://scenes/editor/editor_manager.gd`

3. **Add the following code to `editor_manager.gd`:**

```gdscript
extends Node3D
## Editor Manager - Coordinates all editor systems

@onready var block_palette: BlockPaletteManager = $BlockPaletteManager
@onready var block_placer: BlockPlacer = $BlockPlacer
@onready var editor_ui: CanvasLayer = $EditorUI


func _ready() -> void:
	# Connect block placer to palette
	if block_placer and block_palette:
		block_placer.block_palette = block_palette
		print("[EditorManager] Connected block systems")

	# Connect UI to block placer
	if editor_ui and block_placer:
		editor_ui.block_placer = block_placer
		print("[EditorManager] Connected UI to block placer")
```

4. **Save the scene**

---

## Testing Step 2

Once all scenes are set up, test the block placement system:

### Basic Functionality Tests

1. **Launch the game (F5)**
2. **Enable editor mode (F1)**
3. **Block selection:**
   - Press **1** - Should select Wall
   - Press **2** - Should select Floor
   - Press **3** - Should select Ceiling
   - Press **4** - Should select Ramp
   - Press **5** - Should select Pillar
   - Press **6** - Should select Door Frame
   - Status bar should show current block type

4. **Ghost preview:**
   - Move your mouse around (not holding right-click)
   - You should see a semi-transparent preview of the selected block
   - Preview should follow surfaces and snap to grid
   - Preview should turn **red** if placement is invalid (overlapping existing block)
   - Preview should be **white/transparent** if placement is valid

5. **Block rotation:**
   - Press **R** to rotate the ghost preview
   - Rotation should increment: 0° → 90° → 180° → 270° → 0°
   - Status bar should show current rotation

6. **Block placement:**
   - Position ghost preview where you want to place
   - **Left-click** to place the block
   - Block should become solid and opaque
   - You should NOT be able to place another block in the same spot (ghost turns red)

7. **Block deletion:**
   - **Left-click** on an existing block (NOT holding right-click for camera)
   - Note: This might conflict with camera rotation - try clicking without holding right mouse button first
   - Block should be removed from the scene

### Advanced Tests

8. **Build a simple room:**
   - Place floor blocks (Block 2) in a 5x5 grid
   - Place walls (Block 1) around the perimeter
   - Place ceiling blocks (Block 3) above

9. **Test collision:**
   - Exit editor mode (F1)
   - Walk around as player - you should collide with placed blocks
   - Re-enter editor mode and verify blocks are still there

10. **Console verification:**
    - Check the console output for messages like:
      - `[BlockPlaletteManager] Created 6 block types`
      - `[BlockPlacer] Placed wall at (x, y, z)`
      - `[BlockPlacer] Deleted wall at (x, y, z)`

---

## Troubleshooting

### Ghost preview doesn't appear
- Make sure EditorMode is active (F1)
- Check that BlockPacer has reference to BlockPaletteManager
- Verify raycast is hitting surfaces (try looking at the floor/walls)
- Check console for errors

### Can't place blocks (ghost always red)
- Verify grid snapping is working correctly
- Check that `is_position_valid()` logic is correct
- Try clearing all blocks and placing again

### Blocks don't have collision
- Verify PlaceableBlock scene has CollisionShape3D child
- Check that collision shape is being set in `initialize()` method
- Verify collision layer is set to 1

### Can't delete blocks
- Make sure you're left-clicking on the block (not right-clicking)
- Verify raycast is hitting the block (collision must be on layer 1)
- Check that the hit object is a PlaceableBlock instance

### Block placer script errors
- Verify `placeable_block.tscn` exists and has correct structure
- Check that BlockPaletteManager creates all 6 block types in _ready()
- Ensure EditorCamera reference is set correctly

### UI doesn't show block info
- Verify BlockSelectionLabel exists in EditorUI scene
- Check that editor_ui.block_placer reference is set in editor_manager.gd
- Confirm that update_status_bar() is being called every frame

---

## Keybinds Summary (Steps 1 + 2)

| Key | Action |
|-----|--------|
| **F1** | Toggle editor mode on/off |
| **Right Mouse + Move** | Look around (editor camera) |
| **WASD** | Move horizontally (editor camera) |
| **Q** | Move down (editor camera) |
| **E** | Move up (editor camera) |
| **Shift** | Move faster (editor camera) |
| **Ctrl** | Move slower (editor camera) |
| **1** | Select Wall block |
| **2** | Select Floor block |
| **3** | Select Ceiling block |
| **4** | Select Ramp block |
| **5** | Select Pillar block |
| **6** | Select Door Frame block |
| **R** | Rotate ghost preview (90° increments) |
| **Left Click** | Place block at ghost position |
| **Left Click (on block)** | Delete clicked block |

---

## Known Limitations

- **Delete vs Camera Rotate:** Deletion uses left-click, which might conflict with camera controls. This is a temporary limitation - we'll improve input handling in future steps.
- **No undo yet:** Undo/redo will be implemented in Step 5.
- **No visual feedback for deletion:** Currently just removes the block - we'll add better feedback later.

---

## Step 2 Deliverable

**Goal:** Select blocks from palette, place them with ghost preview, rotate, and delete them.

**Status:** ✅ Code Complete | 📋 Scene Setup Required

Once all scenes are created and tests pass, Step 2 is complete!

---

## Next: Step 3

**Object Palette & Dimension Tagging**

Adds:
- Spawn points, triggers, lights, markers
- Dimension tagging system (Normal, Aztec, Viking, Nightmare)
- Dimension visibility toggling (1-4 keys in editor)
- Tag editor UI for selected blocks/objects
