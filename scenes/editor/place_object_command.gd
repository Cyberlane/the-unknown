extends EditorCommand
class_name PlaceObjectCommand
## Command for placing an object

var object_placer: ObjectPlacer
var object_type: String
var grid_position: Vector3
var properties: Dictionary
var dimension_tags: Array[String]
var placed_object: PlaceableObject = null


func _init(placer: ObjectPlacer, type: String, pos: Vector3, props: Dictionary = {}, tags: Array[String] = []) -> void:
	super._init()
	object_placer = placer
	object_type = type
	grid_position = pos
	properties = props
	dimension_tags = tags if tags.size() > 0 else ["Normal", "Aztec", "Viking", "Nightmare"]
	description = "Place %s at (%d, %d, %d)" % [
		type.replace("_", " ").capitalize(),
		int(pos.x), int(pos.y), int(pos.z)
	]


func execute() -> void:
	if !object_placer or !object_placer.object_palette:
		return

	# Create object
	placed_object = object_placer.object_palette.create_object_instance(
		object_type,
		grid_position,
		properties
	)

	if !placed_object:
		push_error("[PlaceObjectCommand] Failed to create object")
		return

	# Set dimension tags
	placed_object.set_dimension_tags(dimension_tags)

	# Add to scene
	object_placer.level_root.add_child(placed_object)

	# Track the object
	object_placer.placed_objects[placed_object.object_id] = placed_object

	var key := object_placer.get_grid_key(grid_position)
	if !object_placer.objects_at_position.has(key):
		object_placer.objects_at_position[key] = []
	object_placer.objects_at_position[key].append(placed_object)


func undo() -> void:
	if !placed_object or !object_placer:
		return

	# Remove from tracking
	object_placer.placed_objects.erase(placed_object.object_id)

	var key := object_placer.get_grid_key(grid_position)
	if object_placer.objects_at_position.has(key):
		object_placer.objects_at_position[key].erase(placed_object)
		if object_placer.objects_at_position[key].is_empty():
			object_placer.objects_at_position.erase(key)

	# Remove from scene
	placed_object.queue_free()
	placed_object = null
