extends Node
class_name QuickTestManager
## Manages quick-test mode (play level from editor)

signal test_started()
signal test_ended()

var is_testing: bool = false
var saved_editor_camera_position: Vector3 = Vector3.ZERO
var saved_editor_camera_rotation: Vector3 = Vector3.ZERO
var saved_dimension: String = "Normal"
var test_player: Node = null

# References
var object_placer: ObjectPlacer = null
var dimension_filter: DimensionFilter = null


func _ready() -> void:
	print("[QuickTestManager] Initialized")


func _input(event: InputEvent) -> void:
	if !EditorMode.editor_active:
		# In test mode, allow return to editor
		if is_testing and event.is_action_pressed("ui_cancel"):  # Escape key
			end_test()
			get_viewport().set_input_as_handled()
		return

	# Start test with F5 (or custom keybind)
	if event.is_action_pressed("ui_accept") and event.keycode == KEY_F5:
		start_test()
		get_viewport().set_input_as_handled()


## Start quick-test mode
func start_test() -> void:
	if is_testing:
		print("[QuickTestManager] Already testing")
		return

	print("[QuickTestManager] Starting quick-test...")

	# Save editor state
	if EditorMode.editor_camera:
		saved_editor_camera_position = EditorMode.editor_camera.global_position
		saved_editor_camera_rotation = EditorMode.editor_camera.rotation

	if dimension_filter:
		saved_dimension = dimension_filter.get_current_dimension()

	# Find spawn point
	var spawn_position := find_spawn_point()

	# Disable editor mode (keeps editor paused state)
	EditorMode.disable_editor()

	# Spawn player at spawn point
	spawn_test_player(spawn_position)

	# Set dimension to Normal (or saved dimension)
	if DimensionManager:
		DimensionManager.change_dimension("Normal")

	is_testing = true
	test_started.emit()

	print("[QuickTestManager] Test started at %v" % spawn_position)


## End quick-test mode and return to editor
func end_test() -> void:
	if !is_testing:
		print("[QuickTestManager] Not currently testing")
		return

	print("[QuickTestManager] Ending quick-test...")

	# Remove test player
	despawn_test_player()

	# Re-enable editor mode
	EditorMode.enable_editor()

	# Restore editor camera position
	if EditorMode.editor_camera:
		EditorMode.editor_camera.global_position = saved_editor_camera_position
		EditorMode.editor_camera.rotation = saved_editor_camera_rotation

	# Restore dimension view
	if dimension_filter:
		dimension_filter.set_dimension(saved_dimension)

	is_testing = false
	test_ended.emit()

	print("[QuickTestManager] Returned to editor")


## Find a spawn point in the level
func find_spawn_point() -> Vector3:
	# Try to find a PlayerSpawnPoint object
	if object_placer:
		for obj in object_placer.get_all_objects():
			if obj is PlaceableObject and obj.object_type == "player_spawn":
				return obj.global_position

	# Fallback: use editor camera position
	if EditorMode.editor_camera:
		return EditorMode.editor_camera.global_position

	# Last resort: origin
	return Vector3(0, 1, 0)


## Spawn player for testing
func spawn_test_player(position: Vector3) -> void:
	# Try to find existing player in scene
	var player := get_tree().current_scene.get_node_or_null("Player")

	if !player:
		# Player doesn't exist, try to load player scene
		var player_scene := load("res://scenes/player/player.tscn")
		if player_scene:
			test_player = player_scene.instantiate()
			get_tree().current_scene.add_child(test_player)
			player = test_player
		else:
			push_error("[QuickTestManager] Could not load player scene")
			return

	# Position player at spawn point
	if player is CharacterBody3D:
		player.global_position = position
		print("[QuickTestManager] Spawned player at %v" % position)


## Remove test player
func despawn_test_player() -> void:
	# If we created a test player, remove it
	if test_player:
		test_player.queue_free()
		test_player = null

	# Otherwise, keep existing player but may need to reset position
	# (Depending on your game design)
