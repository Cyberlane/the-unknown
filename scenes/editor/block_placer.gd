extends Node
class_name BlockPlacer
## Handles block placement, deletion, and preview in editor mode

# References
var editor_camera: Camera3D
var block_palette: BlockPaletteManager
var level_root: Node3D  # Parent node for placed blocks
var command_history: CommandHistory = null  # For undo/redo

# Ghost preview
var ghost_block: MeshInstance3D = null
var ghost_material_valid: StandardMaterial3D
var ghost_material_invalid: StandardMaterial3D

# Placement state
var current_block_type: String = "wall"
var current_rotation: int = 0
var raycast_distance: float = 100.0
var placement_valid: bool = false
var current_grid_position: Vector3 = Vector3.ZERO

# Placed blocks tracking
var placed_blocks: Dictionary = {}  # grid_position_key -> PlaceableBlock
var blocks_by_id: Dictionary = {}  # block_id -> PlaceableBlock

# Input state
var is_placing: bool = false


func _ready() -> void:
	# Create ghost materials
	ghost_material_valid = BlockResource.create_ghost_material(Color.WHITE, true)
	ghost_material_invalid = BlockResource.create_ghost_material(Color.WHITE, false)

	# Get references
	editor_camera = EditorMode.editor_camera
	if !editor_camera:
		push_error("[BlockPlacer] EditorCamera not found!")

	# Find or create level root
	level_root = get_tree().current_scene.get_node_or_null("PlacedBlocks")
	if !level_root:
		level_root = Node3D.new()
		level_root.name = "PlacedBlocks"
		get_tree().current_scene.add_child(level_root)

	print("[BlockPlacer] Initialized")


func _process(_delta: float) -> void:
	if !EditorMode.editor_active:
		if ghost_block:
			ghost_block.visible = false
		return

	update_ghost_preview()


func _input(event: InputEvent) -> void:
	if !EditorMode.editor_active:
		return

	# Block selection (1-6 keys)
	if event is InputEventKey and event.pressed and !event.echo:
		match event.keycode:
			KEY_1:
				select_block_type("wall")
			KEY_2:
				select_block_type("floor")
			KEY_3:
				select_block_type("ceiling")
			KEY_4:
				select_block_type("ramp")
			KEY_5:
				select_block_type("pillar")
			KEY_6:
				select_block_type("door_frame")

	# Rotation
	if event.is_action_pressed("ui_accept") and event.keycode == KEY_R:
		rotate_ghost()

	# Placement
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			attempt_place_block()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# Only delete if not rotating camera
			if !Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
				attempt_delete_block()


## Update the ghost preview position and validity
func update_ghost_preview() -> void:
	if !editor_camera or !block_palette:
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

		# Check if position is valid
		placement_valid = is_position_valid(current_grid_position)

		# Update ghost
		update_ghost_block()
	else:
		# No hit, hide ghost
		if ghost_block:
			ghost_block.visible = false
			placement_valid = false


## Update the ghost block mesh and material
func update_ghost_block() -> void:
	if !block_palette:
		return

	var block_resource := block_palette.get_block(current_block_type)
	if !block_resource:
		return

	# Create ghost if it doesn't exist
	if !ghost_block:
		ghost_block = MeshInstance3D.new()
		add_child(ghost_block)

	# Update mesh
	ghost_block.mesh = block_resource.mesh

	# Update material based on validity
	if placement_valid:
		ghost_block.material_override = ghost_material_valid
	else:
		ghost_block.material_override = ghost_material_invalid

	# Update position and rotation
	ghost_block.global_position = current_grid_position
	ghost_block.rotation.y = current_rotation * (PI / 2.0)
	ghost_block.visible = true


## Check if a position is valid for placement
func is_position_valid(grid_pos: Vector3) -> bool:
	var key := get_grid_key(grid_pos)
	return !placed_blocks.has(key)


## Attempt to place a block at current ghost position
func attempt_place_block() -> void:
	if !placement_valid or !block_palette:
		print("[BlockPlacer] Cannot place block - invalid position")
		return

	# Use command pattern if available
	if command_history:
		var command := PlaceBlockCommand.new(
			self,
			current_block_type,
			current_grid_position,
			current_rotation
		)
		command_history.execute_command(command)
	else:
		# Fallback: direct placement (no undo)
		place_block_direct(current_block_type, current_grid_position, current_rotation)

	# Emit signal
	EventBus.block_placed.emit(current_block_type, current_grid_position)


## Direct block placement (used by commands or fallback)
func place_block_direct(block_type: String, grid_pos: Vector3, rotation_idx: int) -> PlaceableBlock:
	var block := block_palette.create_block_instance(
		block_type,
		grid_pos,
		rotation_idx
	)

	if !block:
		push_error("[BlockPlacer] Failed to create block instance")
		return null

	# Add to scene
	level_root.add_child(block)

	# Track the block
	var key := get_grid_key(grid_pos)
	placed_blocks[key] = block
	blocks_by_id[block.block_id] = block

	return block


## Attempt to delete a block at raycast position
func attempt_delete_block() -> void:
	if !editor_camera:
		return

	# Perform raycast from camera
	var from := editor_camera.global_position
	var to := from + editor_camera.get_look_direction() * raycast_distance

	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1  # Only hit blocks

	var result := space_state.intersect_ray(query)

	if result and result.collider is PlaceableBlock:
		var block: PlaceableBlock = result.collider

		# Use command pattern if available
		if command_history:
			var command := DeleteBlockCommand.new(self, block)
			command_history.execute_command(command)
		else:
			# Fallback: direct deletion (no undo)
			delete_block(block)


## Delete a specific block
func delete_block(block: PlaceableBlock) -> void:
	if !block:
		return

	# Remove from tracking
	var key := get_grid_key(block.grid_position)
	placed_blocks.erase(key)
	blocks_by_id.erase(block.block_id)

	# Emit signal
	EventBus.block_deleted.emit(block.block_id)

	print("[BlockPlacer] Deleted %s at %v" % [block.block_type, block.grid_position])

	# Remove from scene
	block.queue_free()


## Select a block type for placement
func select_block_type(block_type: String) -> void:
	if block_palette and block_palette.get_block(block_type):
		current_block_type = block_type
		current_rotation = 0  # Reset rotation on new block selection
		print("[BlockPlacer] Selected block: %s" % block_type)


## Rotate the ghost block
func rotate_ghost() -> void:
	current_rotation = (current_rotation + 1) % 4
	print("[BlockPlacer] Rotation: %d" % current_rotation)


## Get a grid key for a position (for dictionary lookup)
func get_grid_key(grid_pos: Vector3) -> String:
	return "%d_%d_%d" % [
		int(grid_pos.x / EditorMode.grid_size),
		int(grid_pos.y / EditorMode.grid_size),
		int(grid_pos.z / EditorMode.grid_size)
	]


## Get block at grid position
func get_block_at_position(grid_pos: Vector3) -> PlaceableBlock:
	var key := get_grid_key(grid_pos)
	return placed_blocks.get(key, null)


## Clear all placed blocks
func clear_all_blocks() -> void:
	for block in placed_blocks.values():
		block.queue_free()

	placed_blocks.clear()
	blocks_by_id.clear()
	print("[BlockPlacer] Cleared all blocks")


## Get all placed blocks
func get_all_blocks() -> Array:
	return placed_blocks.values()


## Get look direction from camera
func get_look_direction() -> Vector3:
	if editor_camera:
		return -editor_camera.global_transform.basis.z
	return Vector3.FORWARD
