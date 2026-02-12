extends CanvasLayer
## Editor UI overlay - shows toolbar, status bar, and editor information

@onready var toolbar: PanelContainer = $Toolbar
@onready var status_bar: PanelContainer = $StatusBar
@onready var mode_label: Label = $Toolbar/MarginContainer/HBoxContainer/ModeLabel
@onready var dimension_label: Label = $Toolbar/MarginContainer/HBoxContainer/DimensionLabel
@onready var camera_pos_label: Label = $StatusBar/MarginContainer/HBoxContainer/CameraPosLabel
@onready var grid_snap_label: Label = $StatusBar/MarginContainer/HBoxContainer/GridSnapLabel
@onready var block_selection_label: Label = $StatusBar/MarginContainer/HBoxContainer/BlockSelectionLabel

# References (set externally)
var block_placer: BlockPlacer = null
var object_placer: ObjectPlacer = null
var dimension_filter: DimensionFilter = null
var save_load_dialog: SaveLoadDialog = null
var autosave_manager: AutosaveManager = null
var command_history: CommandHistory = null
var quick_test_manager: QuickTestManager = null

# Current level name
var current_level_name: String = ""


func _ready() -> void:
	# Register with EditorMode
	EditorMode.editor_ui = self

	# Start hidden
	visible = false

	# Connect to EditorMode signals
	EditorMode.editor_enabled.connect(_on_editor_enabled)
	EditorMode.editor_disabled.connect(_on_editor_disabled)

	# Connect to block placement signals
	EventBus.block_placed.connect(_on_block_placed)
	EventBus.block_deleted.connect(_on_block_deleted)


func _process(_delta: float) -> void:
	if !EditorMode.editor_active:
		return

	update_status_bar()


func _on_editor_enabled() -> void:
	visible = true
	mode_label.text = "EDITOR MODE"
	mode_label.add_theme_color_override("font_color", Color.GREEN)
	update_dimension_display()


func _on_editor_disabled() -> void:
	visible = false


## Update status bar information
func update_status_bar() -> void:
	# Camera position
	if EditorMode.editor_camera:
		var pos := EditorMode.editor_camera.global_position
		camera_pos_label.text = "Camera: %.1f, %.1f, %.1f" % [pos.x, pos.y, pos.z]

	# Grid snap state
	if EditorMode.snap_to_grid:
		grid_snap_label.text = "Grid Snap: ON (%.1fm)" % EditorMode.grid_size
		grid_snap_label.add_theme_color_override("font_color", Color.CYAN)
	else:
		grid_snap_label.text = "Grid Snap: OFF"
		grid_snap_label.add_theme_color_override("font_color", Color.GRAY)

	# Block/Object selection
	var mode_text := ""
	if block_placer and is_block_mode():
		var block_name := block_placer.current_block_type.capitalize()
		mode_text = "Block: %s [%d°]" % [block_name, block_placer.current_rotation * 90]
	elif object_placer and is_object_mode():
		var object_name := object_placer.current_object_type.replace("_", " ").capitalize()
		mode_text = "Object: %s" % object_name

	if !mode_text.is_empty():
		block_selection_label.text = mode_text
		block_selection_label.add_theme_color_override("font_color", Color.YELLOW)

	# Update dimension display
	update_dimension_display()


## Callback when block is placed
func _on_block_placed(block_type: String, position: Vector3) -> void:
	print("[EditorUI] Block placed: %s at %v" % [block_type, position])


## Callback when block is deleted
func _on_block_deleted(block_id: String) -> void:
	print("[EditorUI] Block deleted: %s" % block_id)


## Update dimension display
func update_dimension_display() -> void:
	if !dimension_filter:
		return

	var dimension := dimension_filter.get_current_dimension()
	dimension_label.text = "Dimension: %s" % dimension

	# Color code by dimension
	match dimension:
		"Normal":
			dimension_label.add_theme_color_override("font_color", Color.WHITE)
		"Aztec":
			dimension_label.add_theme_color_override("font_color", Color(1.0, 0.7, 0.2))
		"Viking":
			dimension_label.add_theme_color_override("font_color", Color(0.5, 0.7, 1.0))
		"Nightmare":
			dimension_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))


## Check if currently in block mode
func is_block_mode() -> bool:
	if !block_placer or !block_placer.block_palette:
		return false
	var block_types := block_placer.block_palette.get_all_block_types()
	return block_placer.current_block_type in block_types


## Check if currently in object mode
func is_object_mode() -> bool:
	if !object_placer or !object_placer.object_palette:
		return false
	return object_placer.is_object_mode()


## Handle save button press
func on_save_button_pressed() -> void:
	if save_load_dialog:
		save_load_dialog.open_save_dialog(current_level_name)


## Handle load button press
func on_load_button_pressed() -> void:
	# Check for unsaved changes
	if autosave_manager and autosave_manager.has_unsaved_changes():
		print("[EditorUI] Warning: You have unsaved changes!")
		# TODO: Show confirmation dialog in future

	if save_load_dialog:
		save_load_dialog.open_load_dialog()


## Handle new level button press
func on_new_level_button_pressed() -> void:
	# Check for unsaved changes
	if autosave_manager and autosave_manager.has_unsaved_changes():
		print("[EditorUI] Warning: You have unsaved changes!")
		# TODO: Show confirmation dialog in future

	# Clear level
	if block_placer:
		block_placer.clear_all_blocks()
	if object_placer:
		object_placer.clear_all_objects()

	current_level_name = ""

	if autosave_manager:
		autosave_manager.clear_dirty()

	print("[EditorUI] New level created")


## Callback when level is saved
func _on_level_saved(file_name: String) -> void:
	print("[EditorUI] Level saved: %s" % file_name)
	if autosave_manager:
		autosave_manager.clear_dirty()


## Callback when level is loaded
func _on_level_loaded(file_name: String) -> void:
	current_level_name = file_name.trim_suffix(".json")
	print("[EditorUI] Level loaded: %s" % current_level_name)
	if autosave_manager:
		autosave_manager.mark_dirty()  # Mark as dirty after load (in case of edits)
	if command_history:
		command_history.clear_history()  # Clear undo/redo on load


## Handle undo button press
func on_undo_button_pressed() -> void:
	if command_history:
		command_history.undo()


## Handle redo button press
func on_redo_button_pressed() -> void:
	if command_history:
		command_history.redo()


## Handle quick-test button press
func on_quick_test_button_pressed() -> void:
	if quick_test_manager:
		quick_test_manager.start_test()
