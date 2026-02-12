extends Node
class_name ObjectPaletteManager
## Manages the library of available object types for the editor

# Dictionary of object types: object_type -> properties
var object_library: Dictionary = {}

# Preloaded object scene
const PLACEABLE_OBJECT_SCENE = preload("res://scenes/editor/placeable_object.tscn")


func _ready() -> void:
	create_default_objects()


## Create the default object library
func create_default_objects() -> void:
	# Player Spawn Point
	object_library["player_spawn"] = {
		"display_name": "Player Spawn",
		"description": "Starting position for the player",
		"color": Color.GREEN,
		"default_properties": {
			"spawn_index": 0
		}
	}

	# Interaction Trigger
	object_library["interaction_trigger"] = {
		"display_name": "Interaction Trigger",
		"description": "Trigger area for interactions",
		"color": Color.YELLOW,
		"default_properties": {
			"trigger_radius": 2.0,
			"trigger_event": ""
		}
	}

	# Light Source
	object_library["light_source"] = {
		"display_name": "Light Source",
		"description": "Point or spot light",
		"color": Color.WHITE,
		"default_properties": {
			"light_type": "omni",  # omni or spot
			"light_energy": 1.0,
			"light_color": Color.WHITE,
			"light_range": 5.0
		}
	}

	# Enemy Spawn Marker
	object_library["enemy_spawn"] = {
		"display_name": "Enemy Spawn",
		"description": "Spawn point for enemies",
		"color": Color.RED,
		"default_properties": {
			"enemy_type": "",
			"spawn_on_load": true,
			"respawn_delay": 0.0
		}
	}

	# Trap Marker
	object_library["trap_marker"] = {
		"display_name": "Trap Marker",
		"description": "Marker for trap placement",
		"color": Color.ORANGE,
		"default_properties": {
			"trap_type": "",
			"trigger_mode": "proximity"  # proximity, timed, manual
		}
	}

	print("[ObjectPaletteManager] Created %d object types" % object_library.size())


## Get object info by type
func get_object_info(object_type: String) -> Dictionary:
	return object_library.get(object_type, {})


## Get all object types
func get_all_object_types() -> Array[String]:
	var types: Array[String] = []
	for key in object_library.keys():
		types.append(key)
	return types


## Create a PlaceableObject instance
func create_object_instance(object_type: String, grid_pos: Vector3, properties: Dictionary = {}) -> PlaceableObject:
	var info := get_object_info(object_type)
	if info.is_empty():
		push_error("[ObjectPaletteManager] Object type '%s' not found" % object_type)
		return null

	# Merge default properties with provided properties
	var final_props := info.get("default_properties", {}).duplicate()
	for key in properties:
		final_props[key] = properties[key]

	var object_scene := PLACEABLE_OBJECT_SCENE.instantiate()
	object_scene.initialize(object_type, grid_pos, final_props)
	return object_scene
