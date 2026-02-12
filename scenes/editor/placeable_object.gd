extends Node3D
class_name PlaceableObject
## Base class for non-geometry objects placed in the editor (spawn points, triggers, lights, markers)

# Object metadata
var object_id: String = ""
var object_type: String = ""
var dimension_tags: Array[String] = ["Normal", "Aztec", "Viking", "Nightmare"]  # Visible in all by default

# Visual representation
var gizmo_mesh: MeshInstance3D = null
var gizmo_material: StandardMaterial3D = null

# Grid position (for tracking)
var grid_position: Vector3 = Vector3.ZERO

# Object-specific properties (varies by type)
var properties: Dictionary = {}


func _ready() -> void:
	# Generate unique ID if not set
	if object_id.is_empty():
		object_id = generate_object_id()


## Initialize the object
func initialize(type: String, grid_pos: Vector3, props: Dictionary = {}) -> void:
	object_type = type
	grid_position = grid_pos
	properties = props

	global_position = grid_pos

	# Create visual gizmo
	create_gizmo()


## Generate a unique ID
func generate_object_id() -> String:
	return "object_%s_%d" % [object_type, Time.get_ticks_msec()]


## Create visual gizmo for editor
func create_gizmo() -> void:
	if gizmo_mesh:
		gizmo_mesh.queue_free()

	gizmo_mesh = MeshInstance3D.new()
	add_child(gizmo_mesh)

	# Create gizmo based on type
	match object_type:
		"player_spawn":
			gizmo_mesh.mesh = create_spawn_gizmo()
			gizmo_material = create_gizmo_material(Color.GREEN)
		"interaction_trigger":
			gizmo_mesh.mesh = create_trigger_gizmo()
			gizmo_material = create_gizmo_material(Color.YELLOW)
		"light_source":
			gizmo_mesh.mesh = create_light_gizmo()
			gizmo_material = create_gizmo_material(Color.WHITE)
		"enemy_spawn":
			gizmo_mesh.mesh = create_enemy_gizmo()
			gizmo_material = create_gizmo_material(Color.RED)
		"trap_marker":
			gizmo_mesh.mesh = create_trap_gizmo()
			gizmo_material = create_gizmo_material(Color.ORANGE)

	if gizmo_mesh and gizmo_material:
		gizmo_mesh.material_override = gizmo_material


## Create spawn point gizmo (arrow pointing up)
func create_spawn_gizmo() -> ArrayMesh:
	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_LINES)

	# Vertical line
	surface_tool.add_vertex(Vector3(0, 0, 0))
	surface_tool.add_vertex(Vector3(0, 1.5, 0))

	# Arrow head
	surface_tool.add_vertex(Vector3(0, 1.5, 0))
	surface_tool.add_vertex(Vector3(0.2, 1.2, 0))

	surface_tool.add_vertex(Vector3(0, 1.5, 0))
	surface_tool.add_vertex(Vector3(-0.2, 1.2, 0))

	surface_tool.add_vertex(Vector3(0, 1.5, 0))
	surface_tool.add_vertex(Vector3(0, 1.2, 0.2))

	surface_tool.add_vertex(Vector3(0, 1.5, 0))
	surface_tool.add_vertex(Vector3(0, 1.2, -0.2))

	# Base circle
	var segments := 16
	for i in segments:
		var angle1 := (float(i) / segments) * TAU
		var angle2 := (float(i + 1) / segments) * TAU
		surface_tool.add_vertex(Vector3(cos(angle1) * 0.3, 0, sin(angle1) * 0.3))
		surface_tool.add_vertex(Vector3(cos(angle2) * 0.3, 0, sin(angle2) * 0.3))

	return surface_tool.commit()


## Create trigger gizmo (wireframe box)
func create_trigger_gizmo() -> ArrayMesh:
	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_LINES)

	var size := 0.5

	# Bottom square
	surface_tool.add_vertex(Vector3(-size, 0, -size))
	surface_tool.add_vertex(Vector3(size, 0, -size))

	surface_tool.add_vertex(Vector3(size, 0, -size))
	surface_tool.add_vertex(Vector3(size, 0, size))

	surface_tool.add_vertex(Vector3(size, 0, size))
	surface_tool.add_vertex(Vector3(-size, 0, size))

	surface_tool.add_vertex(Vector3(-size, 0, size))
	surface_tool.add_vertex(Vector3(-size, 0, -size))

	# Top square
	surface_tool.add_vertex(Vector3(-size, size * 2, -size))
	surface_tool.add_vertex(Vector3(size, size * 2, -size))

	surface_tool.add_vertex(Vector3(size, size * 2, -size))
	surface_tool.add_vertex(Vector3(size, size * 2, size))

	surface_tool.add_vertex(Vector3(size, size * 2, size))
	surface_tool.add_vertex(Vector3(-size, size * 2, size))

	surface_tool.add_vertex(Vector3(-size, size * 2, size))
	surface_tool.add_vertex(Vector3(-size, size * 2, -size))

	# Vertical edges
	surface_tool.add_vertex(Vector3(-size, 0, -size))
	surface_tool.add_vertex(Vector3(-size, size * 2, -size))

	surface_tool.add_vertex(Vector3(size, 0, -size))
	surface_tool.add_vertex(Vector3(size, size * 2, -size))

	surface_tool.add_vertex(Vector3(size, 0, size))
	surface_tool.add_vertex(Vector3(size, size * 2, size))

	surface_tool.add_vertex(Vector3(-size, 0, size))
	surface_tool.add_vertex(Vector3(-size, size * 2, size))

	return surface_tool.commit()


## Create light gizmo (sun/star shape)
func create_light_gizmo() -> ArrayMesh:
	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_LINES)

	var size := 0.4

	# Cross lines
	surface_tool.add_vertex(Vector3(-size, 0, 0))
	surface_tool.add_vertex(Vector3(size, 0, 0))

	surface_tool.add_vertex(Vector3(0, -size, 0))
	surface_tool.add_vertex(Vector3(0, size, 0))

	surface_tool.add_vertex(Vector3(0, 0, -size))
	surface_tool.add_vertex(Vector3(0, 0, size))

	# Diagonal lines
	var diag := size * 0.7
	surface_tool.add_vertex(Vector3(-diag, -diag, 0))
	surface_tool.add_vertex(Vector3(diag, diag, 0))

	surface_tool.add_vertex(Vector3(-diag, diag, 0))
	surface_tool.add_vertex(Vector3(diag, -diag, 0))

	surface_tool.add_vertex(Vector3(0, -diag, -diag))
	surface_tool.add_vertex(Vector3(0, diag, diag))

	surface_tool.add_vertex(Vector3(0, -diag, diag))
	surface_tool.add_vertex(Vector3(0, diag, -diag))

	return surface_tool.commit()


## Create enemy spawn gizmo (skull-like shape)
func create_enemy_gizmo() -> ArrayMesh:
	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_LINES)

	# Simple X shape
	var size := 0.5

	surface_tool.add_vertex(Vector3(-size, 0, -size))
	surface_tool.add_vertex(Vector3(size, size, size))

	surface_tool.add_vertex(Vector3(-size, 0, size))
	surface_tool.add_vertex(Vector3(size, size, -size))

	surface_tool.add_vertex(Vector3(size, 0, -size))
	surface_tool.add_vertex(Vector3(-size, size, size))

	surface_tool.add_vertex(Vector3(size, 0, size))
	surface_tool.add_vertex(Vector3(-size, size, -size))

	# Circle at top
	var segments := 12
	for i in segments:
		var angle1 := (float(i) / segments) * TAU
		var angle2 := (float(i + 1) / segments) * TAU
		surface_tool.add_vertex(Vector3(cos(angle1) * 0.3, 0.8, sin(angle1) * 0.3))
		surface_tool.add_vertex(Vector3(cos(angle2) * 0.3, 0.8, sin(angle2) * 0.3))

	return surface_tool.commit()


## Create trap gizmo (warning triangle)
func create_trap_gizmo() -> ArrayMesh:
	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_LINES)

	var size := 0.5

	# Triangle on ground
	surface_tool.add_vertex(Vector3(-size, 0, size * 0.577))
	surface_tool.add_vertex(Vector3(size, 0, size * 0.577))

	surface_tool.add_vertex(Vector3(size, 0, size * 0.577))
	surface_tool.add_vertex(Vector3(0, 0, -size * 0.577))

	surface_tool.add_vertex(Vector3(0, 0, -size * 0.577))
	surface_tool.add_vertex(Vector3(-size, 0, size * 0.577))

	# Exclamation mark in center
	surface_tool.add_vertex(Vector3(0, 0.2, 0))
	surface_tool.add_vertex(Vector3(0, 0.6, 0))

	surface_tool.add_vertex(Vector3(0, 0.1, 0))
	surface_tool.add_vertex(Vector3(0, 0.05, 0))

	return surface_tool.commit()


## Create gizmo material
func create_gizmo_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = false
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.no_depth_test = true  # Always visible through walls
	return material


## Check if this object has a specific dimension tag
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


## Get serialized data for save system
func get_save_data() -> Dictionary:
	return {
		"object_id": object_id,
		"object_type": object_type,
		"position": {
			"x": grid_position.x,
			"y": grid_position.y,
			"z": grid_position.z
		},
		"dimension_tags": dimension_tags,
		"properties": properties
	}


## Load from serialized data
func load_from_data(data: Dictionary) -> void:
	object_id = data.get("object_id", generate_object_id())
	object_type = data.get("object_type", "player_spawn")
	dimension_tags = data.get("dimension_tags", ["Normal", "Aztec", "Viking", "Nightmare"])
	properties = data.get("properties", {})

	var pos_data = data.get("position", {})
	grid_position = Vector3(
		pos_data.get("x", 0),
		pos_data.get("y", 0),
		pos_data.get("z", 0)
	)

	global_position = grid_position
	create_gizmo()
