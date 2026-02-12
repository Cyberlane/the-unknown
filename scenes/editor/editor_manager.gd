extends Node3D
## Editor Manager - Coordinates all editor systems

@onready var block_palette: BlockPaletteManager = $BlockPaletteManager
@onready var block_placer: BlockPlacer = $BlockPlacer
@onready var object_palette: ObjectPaletteManager = $ObjectPaletteManager
@onready var object_placer: ObjectPlacer = $ObjectPlacer
@onready var dimension_filter: DimensionFilter = $DimensionFilter
@onready var level_serializer: LevelSerializer = $LevelSerializer
@onready var autosave_manager: AutosaveManager = $AutosaveManager
@onready var command_history: CommandHistory = $CommandHistory
@onready var quick_test_manager: QuickTestManager = $QuickTestManager
@onready var editor_ui: CanvasLayer = $EditorUI
@onready var dimension_tag_editor: DimensionTagEditor = $EditorUI/DimensionTagEditor
@onready var save_load_dialog: SaveLoadDialog = $EditorUI/SaveLoadDialog


func _ready() -> void:
	# Connect block placer to palette
	if block_placer and block_palette:
		block_placer.block_palette = block_palette
		print("[EditorManager] Connected block systems")
	else:
		if !block_placer:
			push_error("[EditorManager] BlockPlacer not found!")
		if !block_palette:
			push_error("[EditorManager] BlockPaletteManager not found!")

	# Connect object placer to palette
	if object_placer and object_palette:
		object_placer.object_palette = object_palette
		print("[EditorManager] Connected object systems")
	else:
		if !object_placer:
			push_error("[EditorManager] ObjectPlacer not found!")
		if !object_palette:
			push_error("[EditorManager] ObjectPaletteManager not found!")

	# Connect dimension filter to placers
	if dimension_filter:
		dimension_filter.block_placer = block_placer
		dimension_filter.object_placer = object_placer
		print("[EditorManager] Connected dimension filter")

	# Connect UI to systems
	if editor_ui:
		if block_placer:
			editor_ui.block_placer = block_placer
		if object_placer:
			editor_ui.object_placer = object_placer
		if dimension_filter:
			editor_ui.dimension_filter = dimension_filter
		print("[EditorManager] Connected UI to systems")
	else:
		if !editor_ui:
			push_error("[EditorManager] EditorUI not found!")

	# Connect tag editor updates to dimension filter
	if dimension_tag_editor and dimension_filter:
		dimension_tag_editor.tags_updated.connect(_on_tags_updated)

	# Connect level serializer to placers
	if level_serializer:
		level_serializer.block_placer = block_placer
		level_serializer.object_placer = object_placer
		print("[EditorManager] Connected level serializer")

	# Connect autosave manager
	if autosave_manager and level_serializer:
		autosave_manager.level_serializer = level_serializer
		print("[EditorManager] Connected autosave manager")

	# Connect save/load dialog
	if save_load_dialog and level_serializer:
		save_load_dialog.level_serializer = level_serializer
		save_load_dialog.level_saved.connect(_on_level_saved)
		save_load_dialog.level_loaded.connect(_on_level_loaded)
		print("[EditorManager] Connected save/load dialog")

	# Connect command history to placers
	if command_history:
		if block_placer:
			block_placer.command_history = command_history
		if object_placer:
			object_placer.command_history = command_history
		print("[EditorManager] Connected command history")

	# Connect quick test manager
	if quick_test_manager:
		quick_test_manager.object_placer = object_placer
		quick_test_manager.dimension_filter = dimension_filter
		print("[EditorManager] Connected quick test manager")

	# Connect editor UI to systems
	if editor_ui:
		editor_ui.save_load_dialog = save_load_dialog
		editor_ui.autosave_manager = autosave_manager
		editor_ui.command_history = command_history
		editor_ui.quick_test_manager = quick_test_manager


func _input(event: InputEvent) -> void:
	if !EditorMode.editor_active:
		return

	# T key to open dimension tag editor
	if event.is_action_pressed("ui_accept") and event.keycode == KEY_T:
		open_tag_editor_for_selection()


## Open tag editor for currently selected/hovered block or object
func open_tag_editor_for_selection() -> void:
	if !dimension_tag_editor:
		return

	# Try to find block or object under cursor
	var target := get_target_under_cursor()

	if target:
		dimension_tag_editor.open_for_target(target)
	else:
		print("[EditorManager] No block or object under cursor to edit tags")


## Get block or object under cursor (raycast)
func get_target_under_cursor() -> Node:
	var camera := EditorMode.editor_camera
	if !camera:
		return null

	var from := camera.global_position
	var to := from + camera.get_look_direction() * 100.0

	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1

	var result := space_state.intersect_ray(query)

	if result and result.collider:
		if result.collider is PlaceableBlock:
			return result.collider
		elif result.collider.get_parent() is PlaceableObject:
			return result.collider.get_parent()

	return null


## Callback when tags are updated
func _on_tags_updated(new_tags: Array[String]) -> void:
	print("[EditorManager] Tags updated: %s" % str(new_tags))
	# Refresh dimension filter
	if dimension_filter:
		dimension_filter.update_all_visibility()


## Get look direction from camera
func get_look_direction() -> Vector3:
	var camera := EditorMode.editor_camera
	if camera:
		return -camera.global_transform.basis.z
	return Vector3.FORWARD


## Callback when level is saved
func _on_level_saved(file_name: String) -> void:
	print("[EditorManager] Level saved: %s" % file_name)
	if editor_ui:
		editor_ui._on_level_saved(file_name)


## Callback when level is loaded
func _on_level_loaded(file_name: String) -> void:
	print("[EditorManager] Level loaded: %s" % file_name)
	if editor_ui:
		editor_ui._on_level_loaded(file_name)

	# Update dimension filter after loading
	if dimension_filter:
		dimension_filter.update_all_visibility()
