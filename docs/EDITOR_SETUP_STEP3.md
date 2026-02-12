## Editor Mode Setup Guide - Step 3

# Object Palette & Dimension Tagging

This guide walks you through setting up the object placement system and dimension filtering for the level editor.

---

## Files Created

✅ **Scripts:**
- `scenes/editor/placeable_object.gd` - Object instance with gizmo visualization
- `scenes/editor/object_palette_manager.gd` - Object library manager
- `scenes/editor/object_placer.gd` - Object placement system
- `scenes/editor/dimension_filter.gd` - Dimension visibility filtering
- `scenes/editor/dimension_tag_editor.gd` - UI for editing dimension tags
- `scenes/editor/editor_manager.gd` - Updated with object and dimension systems
- `scenes/editor/editor_ui.gd` - Updated with dimension display

**5 Object Types Created:**
1. **Player Spawn** - Green upward arrow (spawn point for player)
2. **Interaction Trigger** - Yellow wireframe box (trigger zones)
3. **Light Source** - White star/sun (light positions)
4. **Enemy Spawn** - Red X with circle (enemy spawn markers)
5. **Trap Marker** - Orange warning triangle (trap positions)

---

## Scene Setup Instructions

### 1. Create PlaceableObject Scene

1. **Create new scene:**
   - Click **Scene → New Scene**
   - Select **Node3D** as root node
   - Rename it to `PlaceableObject`

2. **Attach script:**
   - Select PlaceableObject (root)
   - Click script icon → **Load**
   - Choose `res://scenes/editor/placeable_object.gd`

3. **Save scene:**
   - **Scene → Save Scene As**
   - Save to: `res://scenes/editor/placeable_object.tscn`

---

### 2. Update EditorManager Scene

Add the new systems to EditorManager.

1. **Open `res://scenes/editor/editor_manager.tscn`**

2. **Add ObjectPaletteManager:**
   - Right-click EditorManager → **Add Child Node** → **Node**
   - Rename it to `ObjectPaletteManager`
   - Attach script: `res://scenes/editor/object_palette_manager.gd`

3. **Add ObjectPlacer:**
   - Right-click EditorManager → **Add Child Node** → **Node**
   - Rename it to `ObjectPlacer`
   - Attach script: `res://scenes/editor/object_placer.gd`

4. **Add DimensionFilter:**
   - Right-click EditorManager → **Add Child Node** → **Node**
   - Rename it to `DimensionFilter`
   - Attach script: `res://scenes/editor/dimension_filter.gd`

5. **Update EditorManager script:**
   - The script at `res://scenes/editor/editor_manager.gd` is already updated
   - Just verify it's attached to the root EditorManager node

6. **Save the scene**

---

### 3. Update EditorUI Scene

Add dimension display and tag editor.

1. **Open `res://scenes/editor/editor_ui.tscn`**

2. **Add Dimension Label to Toolbar:**
   - Navigate to: `Toolbar → MarginContainer → HBoxContainer`
   - Right-click HBoxContainer → **Add Child Node** → **Control** (spacer)
     - Size Flags Horizontal: **Expand**
   - Right-click HBoxContainer → **Add Child Node** → **Label**
   - Name it: `DimensionLabel`
   - In Inspector:
     - Text: `Dimension: Normal`
     - Theme Overrides → Font Size: `18`

3. **Add DimensionTagEditor:**
   - Right-click EditorUI (root) → **Add Child Node** → **PanelContainer**
   - Rename it to `DimensionTagEditor`
   - Attach script: `res://scenes/editor/dimension_tag_editor.gd`
   - The UI will be created programmatically by the script

4. **Save the scene**

---

## Testing Step 3

### Part A: Object Placement Tests

1. **Launch game (F5) and enable editor (F1)**

2. **Object Selection:**
   - Press **7** - Should select Player Spawn (green arrow)
   - Press **8** - Should select Interaction Trigger (yellow box)
   - Press **9** - Should select Light Source (white star)
   - Press **0** - Should select Enemy Spawn (red X)
   - Press **-** (minus) - Should select Trap Marker (orange triangle)
   - Status bar should show "Object: [Type]"

3. **Object Preview:**
   - Move mouse around (not holding right-click)
   - You should see a gizmo/icon preview following surfaces
   - Gizmos should be always visible (no depth test)
   - Gizmos should be semi-transparent

4. **Object Placement:**
   - Position preview where you want
   - **Left-click** to place the object
   - Object should stay at that position
   - Multiple objects can be placed at the same location (unlike blocks)

5. **Mixed Placement:**
   - Place some blocks (keys 1-6)
   - Place some objects (keys 7-0)
   - Both should coexist in the scene
   - Objects should be visible through walls (gizmos have no depth test)

### Part B: Dimension Filter Tests

6. **Dimension Switching:**
   - Press **1** - Switch to Normal dimension
     - Toolbar should show "Dimension: Normal" in white
     - All blocks/objects should be visible (default tags)

   - Press **2** - Switch to Aztec dimension
     - Toolbar should show "Dimension: Aztec" in amber/orange
     - Blocks/objects should have amber tint

   - Press **3** - Switch to Viking dimension
     - Toolbar should show "Dimension: Viking" in blue
     - Blocks/objects should have blue tint

   - Press **4** - Switch to Nightmare dimension
     - Toolbar should show "Dimension: Nightmare" in red
     - Blocks/objects should have red tint

7. **Dimension Color Overlays:**
   - Switch between dimensions (1-4)
   - Placed blocks should have colored overlays
   - Object gizmos should be tinted with dimension colors
   - Visible items should reflect current dimension

### Part C: Dimension Tagging Tests

8. **Open Tag Editor:**
   - Aim at a placed block
   - Press **T** key
   - A panel should appear with checkboxes for dimensions
   - All 4 dimensions should be checked by default

9. **Modify Tags:**
   - Uncheck "Normal" and "Viking"
   - Click **Apply**
   - Switch to dimension 1 (Normal) - block should disappear
   - Switch to dimension 2 (Aztec) - block should appear
   - Switch to dimension 3 (Viking) - block should disappear
   - Switch to dimension 4 (Nightmare) - block should appear

10. **Object Tagging:**
    - Aim at a placed object
    - Press **T** key
    - Modify its dimension tags
    - Verify object appears/disappears based on active dimension

11. **Dimension-Specific Level Design:**
    - Create a wall using blocks (key 1)
    - Tag it to only "Viking" dimension
    - Switch to Normal (key 1) - wall should disappear
    - Switch to Viking (key 3) - wall should appear
    - This allows creating dimension-specific geometry!

### Part D: Complex Scenario

12. **Build Multi-Dimension Room:**
    - Create a 5x5 floor (visible in all dimensions)
    - Build north wall - tag it to Normal + Aztec only
    - Build south wall - tag it to Viking + Nightmare only
    - Place enemy spawn - tag it to Nightmare only
    - Place player spawn - tag it to Normal only
    - Switch dimensions and see different configurations

---

## Troubleshooting

### Object preview doesn't appear
- Check that ObjectPaletteManager created 5 object types in console
- Verify object keys 7-0, minus are being pressed
- Check that ObjectPlacer is connected to ObjectPaletteManager

### Gizmos look wrong or invisible
- Verify PlaceableObject.gd is creating gizmos in create_gizmo()
- Check that gizmo material has no_depth_test = true
- Ensure objects are being instantiated correctly

### Dimension switching doesn't work
- Verify DimensionFilter is getting key presses (1-4)
- Check that dimension_filter is connected to block_placer and object_placer
- Ensure update_all_visibility() is being called

### Dimension colors not applying
- Check that blocks/objects have visibility in current dimension
- Verify apply_dimension_overlay() is being called
- Check material_override is being set correctly

### Tag editor doesn't open
- Verify T key press is being detected in editor_manager.gd
- Check that raycast is hitting blocks/objects
- Ensure DimensionTagEditor scene exists under EditorUI

### Tags not saving
- Verify apply button calls _on_apply_pressed()
- Check that set_dimension_tags() is being called on target
- Ensure dimension_filter.update_all_visibility() is called after update

### Objects don't disappear when tags change
- Check that has_dimension_tag() returns correct value
- Verify update_visibility_for_dimension() is setting visible property
- Ensure dimension filter is tracking all placed objects

---

## Keybinds Summary (Steps 1 + 2 + 3)

| Key | Action |
|-----|--------|
| **F1** | Toggle editor mode on/off |
| **Right Mouse + Move** | Look around (editor camera) |
| **WASD** | Move horizontally (editor camera) |
| **Q** | Move down (editor camera) |
| **E** | Move up (editor camera) |
| **Shift** | Move faster (editor camera) |
| **Ctrl** | Move slower (editor camera) |
| **1** | Select Wall block / Switch to Normal dimension* |
| **2** | Select Floor block / Switch to Aztec dimension* |
| **3** | Select Ceiling block / Switch to Viking dimension* |
| **4** | Select Ramp block / Switch to Nightmare dimension* |
| **5** | Select Pillar block |
| **6** | Select Door Frame block |
| **7** | Select Player Spawn object |
| **8** | Select Interaction Trigger object |
| **9** | Select Light Source object |
| **0** | Select Enemy Spawn object |
| **-** (minus) | Select Trap Marker object |
| **R** | Rotate ghost preview (blocks only) |
| **T** | Open dimension tag editor for selected block/object |
| **Left Click** | Place block/object OR Delete block |

*Note: Keys 1-4 are context-sensitive:
- When in block/object selection mode, they select blocks
- After placement, they switch dimensions for filtering

---

## Step 3 Deliverable

**Goal:** Place spawn points, lights, triggers, and markers. Tag objects to dimensions. Toggle dimension visibility with 1-4 keys and see objects show/hide accordingly.

**Status:** ✅ Code Complete | 📋 Scene Setup Required

---

## System Architecture

```
EditorManager (Node3D)
├── BlockPaletteManager (Node) ← 6 block types
├── BlockPlacer (Node) ← Handles blocks
├── ObjectPaletteManager (Node) ← 5 object types
├── ObjectPlacer (Node) ← Handles objects
├── DimensionFilter (Node) ← Dimension visibility
├── EditorCamera (Camera3D)
├── EditorGrid (MeshInstance3D)
└── EditorUI (CanvasLayer)
    ├── Toolbar (shows dimension)
    ├── StatusBar (shows selection)
    └── DimensionTagEditor (PanelContainer)
```

---

## Next: Step 4

**Save/Load System**

Will add:
- Serialize level to JSON (blocks, objects, positions, tags)
- Save/Load UI with file dialogs
- Level metadata (name, author, description)
- Reconstruct levels perfectly from saved data
- Autosave functionality

---

## Notes

- Object gizmos are always visible (no depth test) for easy editing
- Multiple objects can overlap at same position
- Dimension tags default to all 4 dimensions
- Dimension filtering is preview-only in editor (won't affect gameplay)
- Keys 1-4 are context-sensitive (selection vs dimension switching)
