# Editor Mode Setup Guide - Step 4

## Save/Load System

This guide walks you through setting up the save/load system for persistent level storage.

---

## Files Created

✅ **Scripts:**
- `scripts/resources/level_data.gd` - Resource containing level data structure
- `scenes/editor/level_serializer.gd` - JSON serialization/deserialization system
- `scenes/editor/save_load_dialog.gd` - UI dialog for saving and loading
- `scenes/editor/autosave_manager.gd` - Automatic backup system
- Updated `scenes/editor/editor_manager.gd` - Wire up save/load systems
- Updated `scenes/editor/editor_ui.gd` - Save/load button handlers

---

## Scene Setup Instructions

### 1. Update EditorManager Scene

Add the save/load system components.

1. **Open `res://scenes/editor/editor_manager.tscn`**

2. **Add LevelSerializer:**
   - Right-click EditorManager → **Add Child Node** → **Node**
   - Rename it to `LevelSerializer`
   - Attach script: `res://scenes/editor/level_serializer.gd`

3. **Add AutosaveManager:**
   - Right-click EditorManager → **Add Child Node** → **Node**
   - Rename it to `AutosaveManager`
   - Attach script: `res://scenes/editor/autosave_manager.gd`
   - In Inspector, configure properties:
     - Autosave Enabled: `true`
     - Autosave Interval: `300.0` (5 minutes)
     - Autosave Filename: `"autosave.json"`

4. **Save the scene**

---

### 2. Update EditorUI Scene

Add the save/load dialog and toolbar buttons.

1. **Open `res://scenes/editor/editor_ui.tscn`**

2. **Add Save/Load Dialog:**
   - Right-click EditorUI (root) → **Add Child Node** → **PanelContainer**
   - Rename it to `SaveLoadDialog`
   - Attach script: `res://scenes/editor/save_load_dialog.gd`
   - The UI will be created programmatically

3. **Add Save Button to Toolbar:**
   - Navigate to: `Toolbar → MarginContainer → HBoxContainer`
   - Right-click HBoxContainer → **Add Child Node** → **Button**
   - Name it: `SaveButton`
   - In Inspector:
     - Text: `Save`
     - Tooltip Text: `Save level (Ctrl+S)`
   - Connect `pressed` signal to EditorUI script:
     - Select SaveButton
     - Go to Node tab → Signals
     - Double-click `pressed` signal
     - Connect to EditorUI → Method: `on_save_button_pressed`

4. **Add Load Button to Toolbar:**
   - Right-click HBoxContainer (same location) → **Add Child Node** → **Button**
   - Name it: `LoadButton`
   - In Inspector:
     - Text: `Load`
     - Tooltip Text: `Load level (Ctrl+L)`
   - Connect `pressed` signal to EditorUI → Method: `on_load_button_pressed`

5. **Add New Level Button to Toolbar:**
   - Right-click HBoxContainer → **Add Child Node** → **Button**
   - Name it: `NewButton`
   - In Inspector:
     - Text: `New`
     - Tooltip Text: `New level (Ctrl+N)`
   - Connect `pressed` signal to EditorUI → Method: `on_new_level_button_pressed`

6. **Save the scene**

---

## Keyboard Shortcuts (Optional Enhancement)

Add keyboard shortcuts for save/load to `project.godot`:

1. **Open `project.godot` in a text editor**

2. **Add these input actions** (after existing actions):

```ini
save_level={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":true,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":83,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
load_level={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":true,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":76,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
new_level={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":true,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":78,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
```

---

## Testing Step 4

### Part A: Basic Save/Load Tests

1. **Build a test level:**
   - Enable editor mode (F1)
   - Place several blocks (keys 1-6)
   - Place several objects (keys 7-0)
   - Tag some items to specific dimensions (T key)

2. **Save the level:**
   - Click **Save** button in toolbar (or press Ctrl+S)
   - A dialog should appear
   - Enter level name: "Test Level 1"
   - Enter author: "Your Name"
   - Enter description: "My first saved level"
   - Click **Save** button in dialog
   - Console should show: `[LevelSerializer] Saved level to: user://levels/test_level_1.json`

3. **Verify file was created:**
   - Check the user data directory:
     - **Windows:** `%APPDATA%\Godot\app_userdata\The Unknown\levels\`
     - **macOS:** `~/Library/Application Support/Godot/app_userdata/The Unknown/levels/`
     - **Linux:** `~/.local/share/godot/app_userdata/The Unknown/levels/`
   - You should see `test_level_1.json`

4. **Clear the level:**
   - Click **New** button in toolbar
   - All blocks and objects should disappear
   - Scene should be empty

5. **Load the level:**
   - Click **Load** button in toolbar
   - Dialog should appear showing saved levels list
   - "Test Level 1" should appear in the list
   - Select it and click **Load**
   - Level should reconstruct perfectly
   - All blocks and objects should be in correct positions
   - Dimension tags should be preserved

6. **Verify dimension tags:**
   - Switch between dimensions (1-4)
   - Items should appear/disappear based on their tags
   - Tags should match what you set before saving

### Part B: Multiple Levels Test

7. **Save multiple levels:**
   - Build different levels
   - Save each with unique names:
     - "Test Level 2"
     - "Test Level 3"
   - Each should appear in the load list

8. **Switch between levels:**
   - Load "Test Level 1"
   - Verify it loads correctly
   - Click New to clear
   - Load "Test Level 2"
   - Verify it loads correctly

### Part C: Autosave Tests

9. **Make changes after loading:**
   - Load a level
   - Add/remove some blocks
   - Wait 5 minutes (or temporarily change autosave_interval to 10 seconds in scene)
   - Console should show: `[AutosaveManager] Performing autosave...`
   - Console should show: `[AutosaveManager] Autosave successful`

10. **Verify autosave file:**
    - Check levels directory
    - `autosave.json` should exist
    - This is your backup

11. **Test dirty flag:**
    - Load a level
    - Console shows: `[AutosaveManager] Level marked as clean`
    - Place a block
    - Console shows: `[AutosaveManager] Level marked as dirty`
    - Save the level
    - Console shows: `[AutosaveManager] Level marked as clean`

### Part D: Delete Level Test

12. **Delete a saved level:**
    - Click **Load** button
    - Select a level from the list
    - Click **Delete** button
    - Level should disappear from list
    - File should be deleted from disk

### Part E: Complex Level Test

13. **Build a complex level:**
    - Create a multi-room layout with 50+ blocks
    - Add various objects (spawns, triggers, lights)
    - Tag different items to different dimensions
    - Create dimension-specific walls
    - Save it as "Complex Level"

14. **Clear and reload:**
    - Click New to clear
    - Load "Complex Level"
    - Verify all blocks are in correct positions
    - Verify all objects are present
    - Switch dimensions and verify tags work
    - Check rotations are correct

---

## Troubleshooting

### Save dialog doesn't appear
- Verify SaveLoadDialog node exists under EditorUI
- Check that save_load_dialog.gd is attached
- Verify button signal is connected to editor_ui script

### Level doesn't save
- Check console for error messages
- Verify levels directory exists (created automatically)
- Check file permissions in user data directory
- Ensure level name is not empty

### Level loads but blocks/objects missing
- Check console for serialization errors
- Verify block_placer and object_placer are connected to level_serializer
- Check that PlaceableBlock and PlaceableObject scenes exist
- Verify get_save_data() and load_from_data() methods work

### Dimension tags not preserved
- Check that dimension_tags are included in get_save_data()
- Verify load_from_data() sets dimension_tags
- Ensure dimension_filter.update_all_visibility() is called after load

### Autosave doesn't trigger
- Check autosave_enabled is true in AutosaveManager
- Verify autosave_interval is reasonable (300 seconds default)
- Check that level_serializer is connected to autosave_manager
- Look for autosave messages in console

### Can't find saved levels
- Check the correct user data directory for your platform
- Verify LEVELS_DIR constant is "user://levels/"
- Check that populate_levels_list() is scanning directory correctly

### Delete doesn't work
- Verify file exists before delete
- Check file permissions
- Look for error codes in console

---

## Save File Format

The saved JSON has this structure:

```json
{
	"level_name": "Test Level 1",
	"author": "Your Name",
	"description": "My first saved level",
	"creation_date": "2024-01-15T10:30:00",
	"last_modified": "2024-01-15T11:45:00",
	"version": "1.0",
	"default_dimension": "Normal",
	"player_spawn_index": 0,
	"blocks": [
		{
			"block_id": "block_wall_1234567890",
			"block_type": "wall",
			"position": {"x": 0, "y": 0, "z": 0},
			"rotation": 0,
			"dimension_tags": ["Normal", "Aztec", "Viking", "Nightmare"]
		}
	],
	"objects": [
		{
			"object_id": "object_player_spawn_1234567890",
			"object_type": "player_spawn",
			"position": {"x": 0, "y": 1, "z": 5},
			"dimension_tags": ["Normal"],
			"properties": {"spawn_index": 0}
		}
	]
}
```

---

## Keybinds Summary (Steps 1-4)

| Key | Action |
|-----|--------|
| **F1** | Toggle editor mode on/off |
| **Ctrl+S** | Save level (optional shortcut) |
| **Ctrl+L** | Load level (optional shortcut) |
| **Ctrl+N** | New level (optional shortcut) |
| **1-4** | Select blocks / Switch dimensions |
| **5-6** | Select blocks (pillar, door frame) |
| **7-0, -** | Select objects |
| **R** | Rotate block |
| **T** | Edit dimension tags |
| **Left Click** | Place/Delete |

---

## Step 4 Deliverable

**Goal:** Save complex multi-room levels to JSON, exit editor, reload level perfectly with all blocks, objects, and dimension tags intact.

**Status:** ✅ Code Complete | 📋 Scene Setup Required

---

## Next: Step 5

**Undo/Redo & Quick-Test Mode**

Will add:
- Command pattern for undo/redo
- Undo/redo stack (Ctrl+Z, Ctrl+Y)
- Quick-test button (F5) to play level
- Return to editor after testing
- History panel showing recent actions

---

## Notes

- Levels are saved to user data directory (persistent between sessions)
- Autosave creates backup every 5 minutes (configurable)
- Save files are human-readable JSON (can be edited manually)
- Dirty flag tracks unsaved changes
- File names are sanitized (spaces become underscores, lowercase)
- Delete requires confirmation (can be enhanced with dialog)
- Version field allows future format migration
- All dimension tags and properties are preserved
