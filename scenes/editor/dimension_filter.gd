extends Node
class_name DimensionFilter
## Manages dimension filtering and visual overlays in editor mode

# Current dimension being previewed in editor
var current_dimension: String = "Normal"

# Available dimensions
const DIMENSIONS := ["Normal", "Aztec", "Viking", "Nightmare"]

# Dimension colors for overlay
const DIMENSION_COLORS := {
	"Normal": Color(1.0, 1.0, 1.0, 0.3),      # White
	"Aztec": Color(1.0, 0.7, 0.2, 0.3),       # Amber
	"Viking": Color(0.2, 0.5, 1.0, 0.3),      # Blue
	"Nightmare": Color(1.0, 0.2, 0.2, 0.3)    # Red
}

# References to placers for filtering
var block_placer: BlockPlacer = null
var object_placer: ObjectPlacer = null


func _ready() -> void:
	print("[DimensionFilter] Initialized")


func _input(event: InputEvent) -> void:
	if !EditorMode.editor_active:
		return

	# Dimension switching (1-4 keys in editor)
	if event is InputEventKey and event.pressed and !event.echo:
		match event.keycode:
			KEY_1:
				set_dimension("Normal")
			KEY_2:
				set_dimension("Aztec")
			KEY_3:
				set_dimension("Viking")
			KEY_4:
				set_dimension("Nightmare")


## Set the active dimension filter
func set_dimension(dimension: String) -> void:
	if dimension not in DIMENSIONS:
		push_error("[DimensionFilter] Invalid dimension: %s" % dimension)
		return

	if current_dimension == dimension:
		return  # Already on this dimension

	current_dimension = dimension
	print("[DimensionFilter] Switched to %s dimension" % dimension)

	# Update all placed blocks and objects
	update_all_visibility()

	# Emit signal for UI updates
	EventBus.editor_mode_changed.emit(true)  # Reuse for now, can add specific signal later


## Update visibility of all placed blocks and objects based on dimension filter
func update_all_visibility() -> void:
	# Update blocks
	if block_placer:
		for block in block_placer.get_all_blocks():
			if block is PlaceableBlock:
				block.update_visibility_for_dimension(current_dimension)
				# Apply dimension overlay
				apply_dimension_overlay(block)

	# Update objects
	if object_placer:
		for obj in object_placer.get_all_objects():
			if obj is PlaceableObject:
				obj.update_visibility_for_dimension(current_dimension)
				# Apply dimension overlay to gizmo
				apply_object_overlay(obj)


## Apply dimension color overlay to a block
func apply_dimension_overlay(block: PlaceableBlock) -> void:
	if !block or !block.mesh_instance:
		return

	# Only apply overlay if block is visible in current dimension
	if !block.visible:
		return

	# Get dimension color
	var overlay_color := get_dimension_color(current_dimension)

	# Create or update overlay material
	var material := block.mesh_instance.material_override
	if !material or !(material is StandardMaterial3D):
		material = StandardMaterial3D.new()
		material.albedo_color = overlay_color
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		block.mesh_instance.material_override = material
	else:
		# Blend with existing color
		var existing := material as StandardMaterial3D
		existing.albedo_color = Color(
			existing.albedo_color.r * overlay_color.r,
			existing.albedo_color.g * overlay_color.g,
			existing.albedo_color.b * overlay_color.b,
			1.0  # Keep opaque
		)


## Apply dimension overlay to object gizmo
func apply_object_overlay(obj: PlaceableObject) -> void:
	if !obj or !obj.gizmo_mesh or !obj.gizmo_material:
		return

	# Only apply overlay if object is visible in current dimension
	if !obj.visible:
		return

	# Get dimension color
	var overlay_color := get_dimension_color(current_dimension)

	# Tint the gizmo material
	obj.gizmo_material.albedo_color = Color(
		obj.gizmo_material.albedo_color.r * overlay_color.r,
		obj.gizmo_material.albedo_color.g * overlay_color.g,
		obj.gizmo_material.albedo_color.b * overlay_color.b,
		obj.gizmo_material.albedo_color.a
	)


## Get dimension color for overlay
func get_dimension_color(dimension: String) -> Color:
	return DIMENSION_COLORS.get(dimension, Color.WHITE)


## Get current dimension name
func get_current_dimension() -> String:
	return current_dimension


## Cycle to next dimension
func cycle_dimension_forward() -> void:
	var current_idx := DIMENSIONS.find(current_dimension)
	var next_idx := (current_idx + 1) % DIMENSIONS.size()
	set_dimension(DIMENSIONS[next_idx])


## Cycle to previous dimension
func cycle_dimension_backward() -> void:
	var current_idx := DIMENSIONS.find(current_dimension)
	var prev_idx := (current_idx - 1) % DIMENSIONS.size()
	if prev_idx < 0:
		prev_idx = DIMENSIONS.size() - 1
	set_dimension(DIMENSIONS[prev_idx])


## Check if block/object should be visible in current dimension
func is_visible_in_dimension(dimension_tags: Array[String]) -> bool:
	return current_dimension in dimension_tags
