extends Resource
class_name LevelData
## Resource containing all data for a saved level

# Level metadata
@export var level_name: String = "Untitled Level"
@export var author: String = ""
@export var description: String = ""
@export var creation_date: String = ""
@export var last_modified: String = ""
@export var version: String = "1.0"

# Level content
@export var blocks: Array[Dictionary] = []
@export var objects: Array[Dictionary] = []

# Level settings
@export var default_dimension: String = "Normal"
@export var player_spawn_index: int = 0


## Initialize with default values
func _init() -> void:
	creation_date = Time.get_datetime_string_from_system()
	last_modified = creation_date


## Update modification time
func mark_modified() -> void:
	last_modified = Time.get_datetime_string_from_system()


## Get summary info
func get_summary() -> String:
	return "%s - %d blocks, %d objects" % [level_name, blocks.size(), objects.size()]


## Validate level data
func is_valid() -> bool:
	return !level_name.is_empty() and version != ""
