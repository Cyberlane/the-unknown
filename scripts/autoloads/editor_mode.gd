extends Node
## EditorMode singleton - Manages editor state and coordinates editor/play mode switching

signal editor_enabled
signal editor_disabled
signal editor_state_changed(is_active: bool)

var editor_active: bool = false

# Editor settings
var grid_size: float = 1.0  # 1 unit = 1 meter
var grid_visible: bool = true
var snap_to_grid: bool = true

# References (set at runtime)
var editor_camera: Camera3D = null
var player_controller: Node = null
var editor_ui: Control = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_editor"):
		toggle_editor_mode()


## Toggle editor mode on/off
func toggle_editor_mode() -> void:
	editor_active = !editor_active

	if editor_active:
		enable_editor()
	else:
		disable_editor()

	editor_state_changed.emit(editor_active)


## Enable editor mode
func enable_editor() -> void:
	editor_active = true

	# Pause the game
	get_tree().paused = true

	# Disable player controller
	if player_controller:
		player_controller.set_process_mode(Node.PROCESS_MODE_DISABLED)
		if player_controller.has_node("Camera3D"):
			player_controller.get_node("Camera3D").current = false

	# Enable editor camera
	if editor_camera:
		editor_camera.set_process_mode(Node.PROCESS_MODE_ALWAYS)
		editor_camera.current = true
		editor_camera.visible = true

	# Show editor UI
	if editor_ui:
		editor_ui.visible = true

	# Release mouse capture
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	editor_enabled.emit()
	print("[EditorMode] Editor enabled")


## Disable editor mode (return to play mode)
func disable_editor() -> void:
	editor_active = false

	# Unpause the game
	get_tree().paused = false

	# Hide editor camera
	if editor_camera:
		editor_camera.set_process_mode(Node.PROCESS_MODE_DISABLED)
		editor_camera.current = false
		editor_camera.visible = false

	# Enable player controller
	if player_controller:
		player_controller.set_process_mode(Node.PROCESS_MODE_INHERIT)
		if player_controller.has_node("Camera3D"):
			player_controller.get_node("Camera3D").current = true

	# Hide editor UI
	if editor_ui:
		editor_ui.visible = false

	# Capture mouse for player
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	editor_disabled.emit()
	print("[EditorMode] Editor disabled")


## Snap a position to the grid
func snap_position_to_grid(position: Vector3) -> Vector3:
	if !snap_to_grid:
		return position

	return Vector3(
		snappedf(position.x, grid_size),
		snappedf(position.y, grid_size),
		snappedf(position.z, grid_size)
	)


## Snap a rotation to 90-degree increments
func snap_rotation_to_grid(rotation: Vector3) -> Vector3:
	return Vector3(
		snappedf(rotation.x, PI / 2.0),
		snappedf(rotation.y, PI / 2.0),
		snappedf(rotation.z, PI / 2.0)
	)


## Toggle grid visibility
func toggle_grid_visibility() -> void:
	grid_visible = !grid_visible
	EventBus.emit_signal("grid_visibility_changed", grid_visible)


## Toggle snap to grid
func toggle_snap_to_grid() -> void:
	snap_to_grid = !snap_to_grid
	print("[EditorMode] Snap to grid: ", snap_to_grid)
