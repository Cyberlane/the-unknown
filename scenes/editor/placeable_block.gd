extends StaticBody3D
class_name PlaceableBlock
## Individual block instance placed in the editor

# Block metadata
var block_id: String = ""
var block_type: String = ""
var block_resource: BlockResource = null
var dimension_tags: Array[String] = ["Normal", "Aztec", "Viking", "Nightmare"]  # Visible in all by default
var rotation_index: int = 0  # 0-3 for 90-degree increments

# Node references
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

# Grid position (for tracking and serialization)
var grid_position: Vector3 = Vector3.ZERO


func _ready() -> void:
	# Generate unique ID if not set
	if block_id.is_empty():
		block_id = generate_block_id()

	# Set collision layers (blocks on layer 1, interactables on layer 2)
	collision_layer = 1
	collision_mask = 0


## Initialize the block with a block resource
func initialize(resource: BlockResource, grid_pos: Vector3, rotation_idx: int = 0) -> void:
	block_resource = resource
	block_type = resource.block_type
	grid_position = grid_pos
	rotation_index = rotation_idx

	# Set up mesh
	if mesh_instance and resource.mesh:
		mesh_instance.mesh = resource.mesh
		if resource.default_material:
			mesh_instance.material_override = resource.default_material

	# Set up collision
	if collision_shape and resource.collision_shape:
		collision_shape.shape = resource.collision_shape

	# Apply rotation
	rotation.y = rotation_idx * (PI / 2.0)

	# Position at grid location
	global_position = grid_pos


## Generate a unique ID for this block
func generate_block_id() -> String:
	return "block_%s_%d" % [block_type, Time.get_ticks_msec()]


## Check if this block has a specific dimension tag
func has_dimension_tag(dimension: String) -> bool:
	return dimension in dimension_tags


## Add a dimension tag
func add_dimension_tag(dimension: String) -> void:
	if dimension not in dimension_tags:
		dimension_tags.append(dimension)


## Remove a dimension tag
func remove_dimension_tag(dimension: String) -> void:
	dimension_tags.erase(dimension)


## Set dimension tags (replaces existing)
func set_dimension_tags(tags: Array[String]) -> void:
	dimension_tags = tags


## Toggle visibility based on dimension filter
func update_visibility_for_dimension(active_dimension: String) -> void:
	visible = has_dimension_tag(active_dimension)


## Rotate the block 90 degrees clockwise
func rotate_clockwise() -> void:
	rotation_index = (rotation_index + 1) % 4
	rotation.y = rotation_index * (PI / 2.0)


## Rotate the block 90 degrees counter-clockwise
func rotate_counter_clockwise() -> void:
	rotation_index = (rotation_index - 1) % 4
	if rotation_index < 0:
		rotation_index = 3
	rotation.y = rotation_index * (PI / 2.0)


## Get serialized data for save system
func get_save_data() -> Dictionary:
	return {
		"block_id": block_id,
		"block_type": block_type,
		"position": {
			"x": grid_position.x,
			"y": grid_position.y,
			"z": grid_position.z
		},
		"rotation": rotation_index,
		"dimension_tags": dimension_tags
	}


## Load from serialized data
func load_from_data(data: Dictionary) -> void:
	block_id = data.get("block_id", generate_block_id())
	block_type = data.get("block_type", "wall")
	rotation_index = data.get("rotation", 0)
	dimension_tags = data.get("dimension_tags", ["Normal", "Aztec", "Viking", "Nightmare"])

	var pos_data = data.get("position", {})
	grid_position = Vector3(
		pos_data.get("x", 0),
		pos_data.get("y", 0),
		pos_data.get("z", 0)
	)

	global_position = grid_position
	rotation.y = rotation_index * (PI / 2.0)
