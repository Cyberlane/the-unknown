extends Node
class_name BlockPaletteManager
## Manages the library of available block types for the editor

# Dictionary of block resources: block_type -> BlockResource
var block_library: Dictionary = {}

# Preloaded block scene
const PLACEABLE_BLOCK_SCENE = preload("res://scenes/editor/placeable_block.tscn")


func _ready() -> void:
	create_default_blocks()


## Create the default block library
func create_default_blocks() -> void:
	# Wall block
	var wall := BlockResource.new()
	wall.block_type = "wall"
	wall.display_name = "Wall"
	wall.mesh = create_box_mesh(Vector3(1, 2, 1))
	wall.default_material = BlockResource.create_default_material(Color(0.7, 0.7, 0.7))
	wall.collision_shape = create_box_shape(Vector3(1, 2, 1))
	wall.size = Vector3(1, 2, 1)
	block_library["wall"] = wall

	# Floor block
	var floor := BlockResource.new()
	floor.block_type = "floor"
	floor.display_name = "Floor"
	floor.mesh = create_box_mesh(Vector3(1, 0.2, 1))
	floor.default_material = BlockResource.create_default_material(Color(0.6, 0.5, 0.4))
	floor.collision_shape = create_box_shape(Vector3(1, 0.2, 1))
	floor.size = Vector3(1, 0.2, 1)
	block_library["floor"] = floor

	# Ceiling block
	var ceiling := BlockResource.new()
	ceiling.block_type = "ceiling"
	ceiling.display_name = "Ceiling"
	ceiling.mesh = create_box_mesh(Vector3(1, 0.2, 1))
	ceiling.default_material = BlockResource.create_default_material(Color(0.8, 0.8, 0.8))
	ceiling.collision_shape = create_box_shape(Vector3(1, 0.2, 1))
	ceiling.size = Vector3(1, 0.2, 1)
	block_library["ceiling"] = ceiling

	# Ramp block
	var ramp := BlockResource.new()
	ramp.block_type = "ramp"
	ramp.display_name = "Ramp"
	ramp.mesh = create_ramp_mesh()
	ramp.default_material = BlockResource.create_default_material(Color(0.5, 0.6, 0.5))
	ramp.collision_shape = create_box_shape(Vector3(1, 0.5, 1))  # Simplified collision
	ramp.size = Vector3(1, 0.5, 1)
	block_library["ramp"] = ramp

	# Pillar block
	var pillar := BlockResource.new()
	pillar.block_type = "pillar"
	pillar.display_name = "Pillar"
	pillar.mesh = create_box_mesh(Vector3(0.3, 3, 0.3))
	pillar.default_material = BlockResource.create_default_material(Color(0.4, 0.4, 0.4))
	pillar.collision_shape = create_box_shape(Vector3(0.3, 3, 0.3))
	pillar.size = Vector3(0.3, 3, 0.3)
	block_library["pillar"] = pillar

	# Door frame block
	var door_frame := BlockResource.new()
	door_frame.block_type = "door_frame"
	door_frame.display_name = "Door Frame"
	door_frame.mesh = create_door_frame_mesh()
	door_frame.default_material = BlockResource.create_default_material(Color(0.5, 0.4, 0.3))
	door_frame.collision_shape = create_box_shape(Vector3(1, 2.5, 0.2))  # Simplified
	door_frame.size = Vector3(1, 2.5, 0.2)
	block_library["door_frame"] = door_frame

	print("[BlockPaletteManager] Created %d block types" % block_library.size())


## Get a block resource by type
func get_block(block_type: String) -> BlockResource:
	return block_library.get(block_type, null)


## Get all block types
func get_all_block_types() -> Array[String]:
	var types: Array[String] = []
	for key in block_library.keys():
		types.append(key)
	return types


## Create a PlaceableBlock instance from a block type
func create_block_instance(block_type: String, grid_pos: Vector3, rotation_idx: int = 0) -> PlaceableBlock:
	var resource := get_block(block_type)
	if !resource:
		push_error("[BlockPaletteManager] Block type '%s' not found" % block_type)
		return null

	var block_scene := PLACEABLE_BLOCK_SCENE.instantiate()
	block_scene.initialize(resource, grid_pos, rotation_idx)
	return block_scene


## Helper: Create a box mesh
func create_box_mesh(size: Vector3) -> BoxMesh:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh


## Helper: Create a box collision shape
func create_box_shape(size: Vector3) -> BoxShape3D:
	var shape := BoxShape3D.new()
	shape.size = size
	return shape


## Helper: Create a ramp mesh (simple wedge)
func create_ramp_mesh() -> ArrayMesh:
	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Vertices for a simple ramp (wedge shape)
	var verts := [
		# Front face (triangle)
		Vector3(-0.5, 0, 0.5),
		Vector3(0.5, 0, 0.5),
		Vector3(0.5, 1, -0.5),
		Vector3(-0.5, 0, 0.5),
		Vector3(0.5, 1, -0.5),
		Vector3(-0.5, 1, -0.5),

		# Bottom face
		Vector3(-0.5, 0, 0.5),
		Vector3(-0.5, 0, -0.5),
		Vector3(0.5, 0, -0.5),
		Vector3(-0.5, 0, 0.5),
		Vector3(0.5, 0, -0.5),
		Vector3(0.5, 0, 0.5),

		# Back face
		Vector3(-0.5, 0, -0.5),
		Vector3(-0.5, 1, -0.5),
		Vector3(0.5, 1, -0.5),
		Vector3(-0.5, 0, -0.5),
		Vector3(0.5, 1, -0.5),
		Vector3(0.5, 0, -0.5),

		# Left face
		Vector3(-0.5, 0, 0.5),
		Vector3(-0.5, 1, -0.5),
		Vector3(-0.5, 0, -0.5),

		# Right face
		Vector3(0.5, 0, 0.5),
		Vector3(0.5, 0, -0.5),
		Vector3(0.5, 1, -0.5),

		# Top face (sloped)
		Vector3(-0.5, 0, 0.5),
		Vector3(0.5, 0, 0.5),
		Vector3(0.5, 1, -0.5),
		Vector3(-0.5, 0, 0.5),
		Vector3(0.5, 1, -0.5),
		Vector3(-0.5, 1, -0.5),
	]

	for vert in verts:
		surface_tool.add_vertex(vert)

	return surface_tool.commit()


## Helper: Create a door frame mesh (hollow rectangle)
func create_door_frame_mesh() -> ArrayMesh:
	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	var width := 1.0
	var height := 2.5
	var thickness := 0.2
	var frame_width := 0.15

	# Left post
	add_box_to_surface_tool(surface_tool, Vector3(-width/2, height/2, 0), Vector3(frame_width, height, thickness))
	# Right post
	add_box_to_surface_tool(surface_tool, Vector3(width/2, height/2, 0), Vector3(frame_width, height, thickness))
	# Top beam
	add_box_to_surface_tool(surface_tool, Vector3(0, height - frame_width/2, 0), Vector3(width, frame_width, thickness))

	return surface_tool.commit()


## Helper: Add a box to SurfaceTool
func add_box_to_surface_tool(st: SurfaceTool, center: Vector3, size: Vector3) -> void:
	var half_size := size / 2.0
	var vertices := [
		# Front face
		center + Vector3(-half_size.x, -half_size.y, half_size.z),
		center + Vector3(half_size.x, -half_size.y, half_size.z),
		center + Vector3(half_size.x, half_size.y, half_size.z),
		center + Vector3(-half_size.x, -half_size.y, half_size.z),
		center + Vector3(half_size.x, half_size.y, half_size.z),
		center + Vector3(-half_size.x, half_size.y, half_size.z),

		# Back face
		center + Vector3(half_size.x, -half_size.y, -half_size.z),
		center + Vector3(-half_size.x, -half_size.y, -half_size.z),
		center + Vector3(-half_size.x, half_size.y, -half_size.z),
		center + Vector3(half_size.x, -half_size.y, -half_size.z),
		center + Vector3(-half_size.x, half_size.y, -half_size.z),
		center + Vector3(half_size.x, half_size.y, -half_size.z),

		# Left face
		center + Vector3(-half_size.x, -half_size.y, -half_size.z),
		center + Vector3(-half_size.x, -half_size.y, half_size.z),
		center + Vector3(-half_size.x, half_size.y, half_size.z),
		center + Vector3(-half_size.x, -half_size.y, -half_size.z),
		center + Vector3(-half_size.x, half_size.y, half_size.z),
		center + Vector3(-half_size.x, half_size.y, -half_size.z),

		# Right face
		center + Vector3(half_size.x, -half_size.y, half_size.z),
		center + Vector3(half_size.x, -half_size.y, -half_size.z),
		center + Vector3(half_size.x, half_size.y, -half_size.z),
		center + Vector3(half_size.x, -half_size.y, half_size.z),
		center + Vector3(half_size.x, half_size.y, -half_size.z),
		center + Vector3(half_size.x, half_size.y, half_size.z),

		# Top face
		center + Vector3(-half_size.x, half_size.y, half_size.z),
		center + Vector3(half_size.x, half_size.y, half_size.z),
		center + Vector3(half_size.x, half_size.y, -half_size.z),
		center + Vector3(-half_size.x, half_size.y, half_size.z),
		center + Vector3(half_size.x, half_size.y, -half_size.z),
		center + Vector3(-half_size.x, half_size.y, -half_size.z),

		# Bottom face
		center + Vector3(-half_size.x, -half_size.y, -half_size.z),
		center + Vector3(half_size.x, -half_size.y, -half_size.z),
		center + Vector3(half_size.x, -half_size.y, half_size.z),
		center + Vector3(-half_size.x, -half_size.y, -half_size.z),
		center + Vector3(half_size.x, -half_size.y, half_size.z),
		center + Vector3(-half_size.x, -half_size.y, half_size.z),
	]

	for vert in vertices:
		st.add_vertex(vert)
