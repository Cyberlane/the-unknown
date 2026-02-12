extends Node
class_name ObjectPlacer
## Handles object placement and preview in editor mode

# References
var editor_camera: Camera3D
var object_palette: ObjectPaletteManager
var level_root: Node3D  # Parent node for placed objects
var command_history: CommandHistory = null  # For undo/redo

# Ghost preview
var ghost_object: PlaceableObject = null

# Placement state
var current_object_type: String = "player_spawn"
var raycast_distance: float = 100.0
var current_grid_position: Vector3 = Vector3.ZERO

# Placed objects tracking
var placed_objects: Dictionary = {}  # object_id -> PlaceableObject
var objects_at_position: Dictionary = {}  # grid_position_key -> Array[PlaceableObject]


func _ready() -> void:
	# Get references
	editor_camera = EditorMode.editor_camera
	if !editor_camera:
		push_error("[ObjectPlacer] EditorCamera not found!")

	# Find or create level root
	level_root = get_tree().current_scene.get_node_or_null("PlacedObjects")
	if !level_root:
		level_root = Node3D.new()
		level_root.name = "PlacedObjects"
		get_tree().current_scene.add_child(level_root)

	print("[ObjectPlacer] Initialized")


func _process(_delta: float) -> void:
	if !EditorMode.editor_active:
		if ghost_object:
			ghost_object.visible = false
		return

	update_ghost_preview()


func _input(event: InputEvent) -> void:
	if !EditorMode.editor_active:
		return

	# Object selection (7-0 keys)
	if event is InputEventKey and event.pressed and !event.echo:
		match event.keycode:
			KEY_7:
				select_object_type("player_spawn")
			KEY_8:
				select_object_type("interaction_trigger")
			KEY_9:
				select_object_type("light_source")
			KEY_0:
				select_object_type("enemy_spawn")
			KEY_MINUS:  # - key
				select_object_type("trap_marker")

	# Placement (when in object mode)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Check if we're in object mode (not block mode)
			if is_object_mode():
				attempt_place_object()


## Update the ghost preview position
func update_ghost_preview() -> void:
	if !editor_camera or !object_palette or !is_object_mode():
		if ghost_object:
			ghost_object.visible = false
		return

	# Perform raycast from camera
	var from := editor_camera.global_position
	var to := from + editor_camera.get_look_direction() * raycast_distance

	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1  # Only hit blocks and static geometry

	var result := space_state.intersect_ray(query)

	if result:
		# Hit something, place on the surface
		var hit_point: Vector3 = result.position
		var hit_normal: Vector3 = result.normal

		# Offset slightly along normal to place on surface
		var placement_pos := hit_point + hit_normal * 0.1

		# Snap to grid
		current_grid_position = EditorMode.snap_position_to_grid(placement_pos)

		# Update ghost
		update_ghost_object()
	else:
		# No hit, hide ghost
		if ghost_object:
			ghost_object.visible = false


## Update the ghost object
func update_ghost_object() -> void:
	if !object_palette:
		return

	# Create ghost if it doesn't exist
	if !ghost_object:
		ghost_object = object_palette.create_object_instance(current_object_type, current_grid_position)
		if ghost_object:
			add_child(ghost_object)

	# Update type if changed
	if ghost_object and ghost_object.object_type != current_object_type:
		ghost_object.queue_free()
		ghost_object = object_palette.create_object_instance(current_object_type, current_grid_position)
		if ghost_object:
			add_child(ghost_object)

	# Update position
	if ghost_object:
		ghost_object.global_position = current_grid_position
		ghost_object.visible = true

		# Make ghost semi-transparent
		if ghost_object.gizmo_mesh and ghost_object.gizmo_material:
			ghost_object.gizmo_material.albedo_color.a = 0.5


## Check if we're in object mode (not block mode)
func is_object_mode() -> bool:
	# Object mode if current type is an object type
	return object_palette and object_palette.get_object_info(current_object_type).size() > 0


## Attempt to place an object at current ghost position
func attempt_place_object() -> void:
	if !object_palette:
		print("[ObjectPlacer] Cannot place object - no palette")
		return

	# Use command pattern if available
	if command_history:
		var command := PlaceObjectCommand.new(
			self,
			current_object_type,
			current_grid_position
		)
		command_history.execute_command(command)
	else:
		# Fallback: direct placement (no undo)
		place_object_direct(current_object_type, current_grid_position)


## Direct object placement (used by commands or fallback)
func place_object_direct(object_type: String, grid_pos: Vector3, props: Dictionary = {}) -> PlaceableObject:
	var obj := object_palette.create_object_instance(
		object_type,
		grid_pos,
		props
	)

	if !obj:
		push_error("[ObjectPlacer] Failed to create object instance")
		return null

	# Add to scene
	level_root.add_child(obj)

	# Track the object
	placed_objects[obj.object_id] = obj

	# Track objects at this position
	var key := get_grid_key(grid_pos)
	if !objects_at_position.has(key):
		objects_at_position[key] = []
	objects_at_position[key].append(obj)

	return obj


## Delete an object
func delete_object(obj: PlaceableObject) -> void:
	if !obj:
		return

	# Remove from tracking
	placed_objects.erase(obj.object_id)

	var key := get_grid_key(obj.grid_position)
	if objects_at_position.has(key):
		objects_at_position[key].erase(obj)
		if objects_at_position[key].is_empty():
			objects_at_position.erase(key)

	print("[ObjectPlacer] Deleted %s at %v" % [obj.object_type, obj.grid_position])

	# Remove from scene
	obj.queue_free()


## Select an object type for placement
func select_object_type(object_type: String) -> void:
	if object_palette and !object_palette.get_object_info(object_type).is_empty():
		current_object_type = object_type
		print("[ObjectPlacer] Selected object: %s" % object_type)


## Get a grid key for a position
func get_grid_key(grid_pos: Vector3) -> String:
	return "%d_%d_%d" % [
		int(grid_pos.x / EditorMode.grid_size),
		int(grid_pos.y / EditorMode.grid_size),
		int(grid_pos.z / EditorMode.grid_size)
	]


## Get objects at grid position
func get_objects_at_position(grid_pos: Vector3) -> Array:
	var key := get_grid_key(grid_pos)
	return objects_at_position.get(key, [])


## Clear all placed objects
func clear_all_objects() -> void:
	for obj in placed_objects.values():
		obj.queue_free()

	placed_objects.clear()
	objects_at_position.clear()
	print("[ObjectPlacer] Cleared all objects")


## Get all placed objects
func get_all_objects() -> Array:
	return placed_objects.values()


## Get look direction from camera
func get_look_direction() -> Vector3:
	if editor_camera:
		return -editor_camera.global_transform.basis.z
	return Vector3.FORWARD
