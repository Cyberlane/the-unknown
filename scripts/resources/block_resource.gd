extends Resource
class_name BlockResource
## Resource definition for placeable blocks in the level editor

@export var block_type: String = "wall"
@export var display_name: String = "Wall"
@export var mesh: Mesh
@export var default_material: Material
@export var collision_shape: Shape3D
@export var icon_texture: Texture2D  # For UI display

# Block dimensions (for grid snapping and collision)
@export var size: Vector3 = Vector3(1, 1, 1)

# Can this block be rotated?
@export var rotatable: bool = true

# Default rotation (in 90-degree increments, 0-3)
@export var default_rotation: int = 0


## Create a default material for this block
static func create_default_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	return material


## Create a ghost material (semi-transparent) for placement preview
static func create_ghost_material(color: Color, is_valid: bool = true) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()

	if is_valid:
		material.albedo_color = Color(color.r, color.g, color.b, 0.5)
	else:
		material.albedo_color = Color(1.0, 0.3, 0.3, 0.5)  # Red tint for invalid placement

	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	return material
