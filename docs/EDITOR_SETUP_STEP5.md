# Editor Mode Setup Guide - Step 5

## Undo/Redo & Quick-Test Mode

This guide walks you through setting up undo/redo functionality and quick-test mode for the level editor.

---

## Files Created

✅ **Scripts:**
- `scenes/editor/editor_command.gd` - Base class for command pattern
- `scenes/editor/place_block_command.gd` - Command for placing blocks
- `scenes/editor/delete_block_command.gd` - Command for deleting blocks
- `scenes/editor/place_object_command.gd` - Command for placing objects
- `scenes/editor/command_history.gd` - Undo/redo stack manager
- `scenes/editor/quick_test_manager.gd` - Quick-test mode system
- Updated `scenes/editor/block_placer.gd` - Use command pattern
- Updated `scenes/editor/object_placer.gd` - Use command pattern
- Updated `scenes/editor/editor_manager.gd` - Wire up new systems
- Updated `scenes/editor/editor_ui.gd` - Add button handlers
- Updated `project.godot` - Added ui_undo and ui_redo input actions

---

## Scene Setup Instructions

### 1. Update EditorManager Scene

Add the undo/redo and quick-test systems.

1. **Open `res://scenes/editor/editor_manager.tscn`**

2. **Add CommandHistory:**
   - Right-click EditorManager → **Add Child Node** → **Node**
   - Rename it to `CommandHistory`
   - Attach script: `res://scenes/editor/command_history.gd`
   - In Inspector, configure properties:
     - Max History: `100` (number of undoable actions)

3. **Add QuickTestManager:**
   - Right-click EditorManager → **Add Child Node** → **Node**
   - Rename it to `QuickTestManager`
   - Attach script: `res://scenes/editor/quick_test_manager.gd`

4. **Save the scene**

---

### 2. Update EditorUI Scene

Add undo, redo, and quick-test buttons to the toolbar.

1. **Open `res://scenes/editor/editor_ui.tscn`**

2. **Add Undo Button:**
   - Navigate to: `Toolbar → MarginContainer → HBoxContainer`
   - Right-click HBoxContainer → **Add Child Node** → **Button**
   - Name it: `UndoButton`
   - In Inspector:
     - Text: `Undo`
     - Tooltip Text: `Undo last action (Ctrl+Z)`
   - Connect `pressed` signal to EditorUI → Method: `on_undo_button_pressed`

3. **Add Redo Button:**
   - Right-click HBoxContainer → **Add Child Node** → **Button**
   - Name it: `RedoButton`
   - In Inspector:
     - Text: `Redo`
     - Tooltip Text: `Redo last undone action (Ctrl+Y)`
   - Connect `pressed` signal to EditorUI → Method: `on_redo_button_pressed`

4. **Add Spacer (optional):**
   - Right-click HBoxContainer → **Add Child Node** → **Control**
   - Size Flags Horizontal: **Expand** (pushes quick-test to the right)

5. **Add Quick-Test Button:**
   - Right-click HBoxContainer → **Add Child Node** → **Button**
   - Name it: `QuickTestButton`
   - In Inspector:
     - Text: `▶ Test`
     - Tooltip Text: `Quick-test level (F5)`
   - Connect `pressed` signal to EditorUI → Method: `on_quick_test_button_pressed`

6. **Save the scene**

---

## Testing Step 5

### Part A: Undo/Redo Tests

1. **Enable editor mode (F1)**

2. **Place a block:**
   - Select Wall (key 1)
   - Left-click to place
   - Block should appear
   - Console: `[CommandHistory] Executed: Place Wall at (x, y, z)`

3. **Undo the placement:**
   - Press **Ctrl+Z** or click **Undo** button
   - Block should disappear
   - Console: `[CommandHistory] Undone: Place Wall at (x, y, z)`

4. **Redo the placement:**
   - Press **Ctrl+Y** or click **Redo** button
   - Block should reappear
   - Console: `[CommandHistory] Redone: Place Wall at (x, y, z)`

5. **Multiple actions:**
   - Place 5 different blocks
   - Press Ctrl+Z five times
   - All 5 blocks should disappear (in reverse order)
   - Press Ctrl+Y five times
   - All 5 blocks should reappear (in original order)

6. **Delete with undo:**
   - Place a block
   - Left-click on it to delete
   - Console: `[CommandHistory] Executed: Delete Wall at (x, y, z)`
   - Press Ctrl+Z
   - Block should reappear!
   - Press Ctrl+Z again
   - Block should disappear (undoing the original place)

7. **Object placement with undo:**
   - Place a Player Spawn (key 7)
   - Press Ctrl+Z - object disappears
   - Press Ctrl+Y - object reappears

8. **Undo invalidates redo:**
   - Place 3 blocks
   - Undo 2 times (1 block remaining)
   - Place a new block (different location)
   - Try to redo - nothing happens (redo stack cleared)

### Part B: Quick-Test Mode Tests

9. **Place a spawn point:**
   - Press key 7 (Player Spawn)
   - Click to place at a desired location
   - Note the position

10. **Start quick-test:**
    - Press **F5** or click **▶ Test** button
    - Editor UI should disappear
    - Player should spawn at the spawn point location
    - Game should be in play mode (not paused)
    - Console: `[QuickTestManager] Test started at (x, y, z)`

11. **Test gameplay:**
    - Move around with WASD
    - Player should collide with placed blocks
    - Camera controls should work normally

12. **Return to editor:**
    - Press **Escape** key
    - Editor should re-enable
    - Editor UI should reappear
    - Editor camera should return to previous position
    - Console: `[QuickTestManager] Returned to editor`

13. **Quick-test without spawn point:**
    - Clear all objects (or don't place spawn point)
    - Press F5
    - Player should spawn at editor camera position (fallback)

14. **Test after editing:**
    - Build a small room with blocks
    - Place a spawn point inside
    - Press F5 to test
    - Walk around the room
    - Press Escape to return
    - Continue editing
    - Press F5 again to re-test

### Part C: Integration Tests

15. **Undo after save/load:**
    - Place several blocks
    - Save the level
    - Place more blocks
    - Undo - new blocks disappear
    - Undo more - saved blocks should also undo
    - Load the level
    - Undo history should clear
    - Try Ctrl+Z - nothing happens (fresh load)

16. **Complex workflow:**
    - Build a room (10+ blocks)
    - Tag some blocks to specific dimensions
    - Save the level
    - Make changes (place, delete)
    - Undo some changes (Ctrl+Z x3)
    - Quick-test the level (F5)
    - Walk around
    - Return to editor (Escape)
    - Save the level
    - Load the level
    - Quick-test again

### Part D: Edge Cases

17. **Undo limit test:**
    - Place 110 blocks (more than max_history of 100)
    - Try to undo all
    - Should only undo last 100 (oldest 10 are gone)

18. **Undo when nothing to undo:**
    - Fresh level (or after load)
    - Press Ctrl+Z
    - Console: `[CommandHistory] Nothing to undo`
    - No crashes

19. **Quick-test in empty level:**
    - Clear level (New button)
    - Press F5
    - Player spawns at origin (0, 1, 0)
    - No crashes

### Part E: Console Verification

- [ ] Check for: `[CommandHistory] Initialized with max history: 100`
- [ ] Check for: `[CommandHistory] Executed: [description]`
- [ ] Check for: `[CommandHistory] Undone: [description]`
- [ ] Check for: `[CommandHistory] Redone: [description]`
- [ ] Check for: `[QuickTestManager] Initialized`
- [ ] Check for: `[QuickTestManager] Starting quick-test...`
- [ ] Check for: `[QuickTestManager] Test started at [position]`
- [ ] Check for: `[QuickTestManager] Ending quick-test...`
- [ ] Check for: `[QuickTestManager] Returned to editor`
- [ ] No error messages in console

---

## Troubleshooting

### Undo doesn't work
- Verify CommandHistory node exists in EditorManager
- Check that command_history is connected to block_placer and object_placer
- Verify ui_undo input action exists in project.godot
- Check console for command execution messages

### Redo doesn't work
- Verify redo_stack is being populated on undo
- Check ui_redo input action exists
- Ensure new actions clear redo stack (expected behavior)

### Commands not using undo system
- Verify command_history reference is set in placers
- Check that PlaceBlockCommand and DeleteBlockCommand classes exist
- Ensure execute_command() is being called

### Quick-test doesn't start
- Verify QuickTestManager node exists
- Check F5 key handling in quick_test_manager.gd
- Ensure player scene exists at res://scenes/player/player.tscn
- Look for error messages in console

### Player doesn't spawn
- Check that Player scene can be loaded
- Verify spawn point finding logic
- Check fallback to editor camera position
- Ensure player is CharacterBody3D

### Can't return from quick-test
- Verify Escape key handling
- Check that EditorMode.enable_editor() is called
- Ensure editor camera position is restored

### Undo brings back deleted block in wrong place
- Check that block_data in DeleteBlockCommand stores all info
- Verify load_from_data() restores position correctly
- Ensure grid_position is saved/restored

---

## Keybinds Summary (Complete Editor)

| Key | Action |
|-----|--------|
| **F1** | Toggle editor mode on/off |
| **F5** | Quick-test level (play from spawn) |
| **Escape** | Return to editor (from quick-test) |
| **Ctrl+Z** | Undo last action |
| **Ctrl+Y** | Redo last undone action |
| **Ctrl+S** | Save level (optional) |
| **Ctrl+L** | Load level (optional) |
| **Ctrl+N** | New level (optional) |
| **Right Mouse + Move** | Look around (editor camera) |
| **WASD** | Move horizontally (editor camera) |
| **Q** | Move down (editor camera) |
| **E** | Move up (editor camera) |
| **Shift** | Move faster (editor camera) |
| **Ctrl** | Move slower (editor camera) |
| **1-4** | Select blocks / Switch dimensions |
| **5-6** | Select blocks (pillar, door frame) |
| **7-0, -** | Select objects |
| **R** | Rotate block |
| **T** | Edit dimension tags |
| **G** | Toggle grid visibility |
| **H** | Show help (planned) |
| **Left Click** | Place/Delete |

---

## Step 5 Deliverable

**Goal:** Undo/redo all editing actions. Press F5 to instantly play-test from a spawn point, then return to editing with full state preserved.

**Status:** ✅ Code Complete | 📋 Scene Setup Required

---

## System Architecture

```
EditorManager (Node3D)
├── BlockPaletteManager
├── BlockPlacer ←────────┬─── Uses commands
├── ObjectPaletteManager  │
├── ObjectPlacer ←────────┤
├── DimensionFilter       │
├── LevelSerializer       │
├── AutosaveManager       │
├── CommandHistory ←──────┘  Undo/Redo stack
├── QuickTestManager ← Tests level
├── EditorCamera
├── EditorGrid
└── EditorUI (CanvasLayer)
    ├── Toolbar (Undo/Redo/Test buttons)
    └── ...
```

---

## Command Pattern Flow

```
User Action (place block)
    ↓
BlockPlacer.attempt_place_block()
    ↓
Create PlaceBlockCommand
    ↓
CommandHistory.execute_command()
    ↓
command.execute() → Block placed
    ↓
Add to undo_stack
    ↓
Clear redo_stack

User presses Ctrl+Z
    ↓
CommandHistory.undo()
    ↓
Pop from undo_stack
    ↓
command.undo() → Block removed
    ↓
Add to redo_stack
```

---

## Quick-Test Flow

```
User presses F5
    ↓
QuickTestManager.start_test()
    ↓
Save editor state (camera pos, dimension)
    ↓
Find spawn point (or use camera pos)
    ↓
EditorMode.disable_editor()
    ↓
Spawn/position player
    ↓
Enter play mode

User presses Escape
    ↓
QuickTestManager.end_test()
    ↓
Remove/reposition player
    ↓
EditorMode.enable_editor()
    ↓
Restore camera position
    ↓
Restore dimension view
    ↓
Return to editing
```

---

## Congratulations!

🎉 **You've completed Stage 2 - Level Editor!**

You now have a fully functional in-game level editor with:
- ✅ Free-fly camera with grid snapping
- ✅ 6 block types (wall, floor, ceiling, ramp, pillar, door frame)
- ✅ 5 object types (spawns, triggers, lights, markers)
- ✅ 4 dimensions with tagging and filtering
- ✅ Save/Load system with JSON serialization
- ✅ Autosave with dirty flag tracking
- ✅ Full undo/redo support (100 action history)
- ✅ Quick-test mode for instant playtesting

**Next Steps:**
- Use this editor to create levels for Stage 3 (Dimension System)
- Build dimension-specific puzzles and layouts
- Test gameplay flows with quick-test
- Save level templates for procedural generation (Stage 9)

---

## Notes

- Undo/redo works for block placement, deletion (object support is basic)
- Command history limited to 100 actions (configurable)
- Quick-test requires player scene at res://scenes/player/player.tscn
- Escape key returns from test (ui_cancel action)
- Editor state fully preserved during quick-test
- All keybinds are customizable in project settings
