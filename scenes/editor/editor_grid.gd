extends MeshInstance3D
## Visual grid for editor mode - shows grid lines for placement reference

@export var grid_size: float = 1.0
@export var grid_extent: int = 50  # How many units in each direction
@export var grid_color: Color = Color(0.5, 0.5, 0.5, 0.3)
@export var center_line_color: Color = Color(0.8, 0.8, 0.8, 0.5)


func _ready() -> void:
	create_grid_mesh()

	# Listen for grid visibility changes
	EventBus.connect("grid_visibility_changed", _on_grid_visibility_changed)

	# Start hidden if editor not active
	visible = EditorMode.editor_active and EditorMode.grid_visible


func create_grid_mesh() -> void:
	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_LINES)

	# Draw grid lines
	for i in range(-grid_extent, grid_extent + 1):
		var offset := float(i) * grid_size

		# Lines parallel to X-axis (running along Z)
		var color := center_line_color if i == 0 else grid_color
		surface_tool.set_color(color)
		surface_tool.add_vertex(Vector3(-grid_extent * grid_size, 0, offset))
		surface_tool.add_vertex(Vector3(grid_extent * grid_size, 0, offset))

		# Lines parallel to Z-axis (running along X)
		surface_tool.set_color(color)
		surface_tool.add_vertex(Vector3(offset, 0, -grid_extent * grid_size))
		surface_tool.add_vertex(Vector3(offset, 0, grid_extent * grid_size))

	mesh = surface_tool.commit()

	# Create material for the grid
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.no_depth_test = true

	set_surface_override_material(0, material)


func _on_grid_visibility_changed(is_visible: bool) -> void:
	visible = is_visible and EditorMode.editor_active


## Update grid when settings change
func update_grid() -> void:
	grid_size = EditorMode.grid_size
	create_grid_mesh()
