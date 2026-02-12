extends Node
class_name LevelSerializer
## Handles serialization and deserialization of level data to/from JSON

# Save directory
const LEVELS_DIR := "user://levels/"

# References to editor systems
var block_placer: BlockPlacer = null
var object_placer: ObjectPlacer = null


func _ready() -> void:
	# Ensure levels directory exists
	ensure_levels_directory()


## Ensure the levels directory exists
func ensure_levels_directory() -> void:
	if !DirAccess.dir_exists_absolute(LEVELS_DIR):
		var err := DirAccess.make_dir_absolute(LEVELS_DIR)
		if err == OK:
			print("[LevelSerializer] Created levels directory: %s" % LEVELS_DIR)
		else:
			push_error("[LevelSerializer] Failed to create levels directory: %d" % err)


## Serialize current level to LevelData resource
func serialize_level(level_name: String, metadata: Dictionary = {}) -> LevelData:
	var level_data := LevelData.new()

	# Set metadata
	level_data.level_name = level_name
	level_data.author = metadata.get("author", "")
	level_data.description = metadata.get("description", "")
	level_data.mark_modified()

	# Serialize blocks
	if block_placer:
		for block in block_placer.get_all_blocks():
			if block is PlaceableBlock:
				level_data.blocks.append(block.get_save_data())

	# Serialize objects
	if object_placer:
		for obj in object_placer.get_all_objects():
			if obj is PlaceableObject:
				level_data.objects.append(obj.get_save_data())

	print("[LevelSerializer] Serialized level: %s (%d blocks, %d objects)" % [
		level_name,
		level_data.blocks.size(),
		level_data.objects.size()
	])

	return level_data


## Save level data to JSON file
func save_level_to_file(level_data: LevelData, file_name: String = "") -> bool:
	if !level_data.is_valid():
		push_error("[LevelSerializer] Invalid level data")
		return false

	# Generate filename if not provided
	if file_name.is_empty():
		file_name = sanitize_filename(level_data.level_name) + ".json"

	var file_path := LEVELS_DIR + file_name

	# Convert to dictionary
	var data_dict := {
		"level_name": level_data.level_name,
		"author": level_data.author,
		"description": level_data.description,
		"creation_date": level_data.creation_date,
		"last_modified": level_data.last_modified,
		"version": level_data.version,
		"default_dimension": level_data.default_dimension,
		"player_spawn_index": level_data.player_spawn_index,
		"blocks": level_data.blocks,
		"objects": level_data.objects
	}

	# Convert to JSON string
	var json_string := JSON.stringify(data_dict, "\t")  # Pretty print with tabs

	# Write to file
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if !file:
		push_error("[LevelSerializer] Failed to open file for writing: %s" % file_path)
		return false

	file.store_string(json_string)
	file.close()

	print("[LevelSerializer] Saved level to: %s" % file_path)
	return true


## Load level data from JSON file
func load_level_from_file(file_path: String) -> LevelData:
	# Check if file exists
	if !FileAccess.file_exists(file_path):
		push_error("[LevelSerializer] File not found: %s" % file_path)
		return null

	# Read file
	var file := FileAccess.open(file_path, FileAccess.READ)
	if !file:
		push_error("[LevelSerializer] Failed to open file for reading: %s" % file_path)
		return null

	var json_string := file.get_as_text()
	file.close()

	# Parse JSON
	var level_data := deserialize_level(json_string)

	if level_data:
		print("[LevelSerializer] Loaded level: %s (%d blocks, %d objects)" % [
			level_data.level_name,
			level_data.blocks.size(),
			level_data.objects.size()
		])

	return level_data


## Deserialize JSON string to LevelData resource
func deserialize_level(json_string: String) -> LevelData:
	var json := JSON.new()
	var error := json.parse(json_string)

	if error != OK:
		push_error("[LevelSerializer] JSON parse error: %s at line %d" % [
			json.get_error_message(),
			json.get_error_line()
		])
		return null

	var data_dict: Dictionary = json.data

	# Create LevelData resource
	var level_data := LevelData.new()
	level_data.level_name = data_dict.get("level_name", "Untitled Level")
	level_data.author = data_dict.get("author", "")
	level_data.description = data_dict.get("description", "")
	level_data.creation_date = data_dict.get("creation_date", "")
	level_data.last_modified = data_dict.get("last_modified", "")
	level_data.version = data_dict.get("version", "1.0")
	level_data.default_dimension = data_dict.get("default_dimension", "Normal")
	level_data.player_spawn_index = data_dict.get("player_spawn_index", 0)

	# Get blocks and objects arrays
	var blocks_array: Array = data_dict.get("blocks", [])
	var objects_array: Array = data_dict.get("objects", [])

	# Convert to Dictionary arrays
	for block_data in blocks_array:
		if block_data is Dictionary:
			level_data.blocks.append(block_data)

	for object_data in objects_array:
		if object_data is Dictionary:
			level_data.objects.append(object_data)

	return level_data


## Build level from LevelData (reconstruct scene)
func build_level_from_data(level_data: LevelData) -> bool:
	if !level_data or !level_data.is_valid():
		push_error("[LevelSerializer] Invalid level data")
		return false

	print("[LevelSerializer] Building level: %s" % level_data.level_name)

	# Clear existing level
	clear_current_level()

	# Reconstruct blocks
	var blocks_created := 0
	for block_data in level_data.blocks:
		if create_block_from_data(block_data):
			blocks_created += 1

	# Reconstruct objects
	var objects_created := 0
	for object_data in level_data.objects:
		if create_object_from_data(object_data):
			objects_created += 1

	print("[LevelSerializer] Level built: %d blocks, %d objects" % [
		blocks_created,
		objects_created
	])

	return true


## Create a block from saved data
func create_block_from_data(data: Dictionary) -> bool:
	if !block_placer or !block_placer.block_palette:
		return false

	var block_type: String = data.get("block_type", "")
	var rotation: int = data.get("rotation", 0)

	var pos_data: Dictionary = data.get("position", {})
	var grid_pos := Vector3(
		pos_data.get("x", 0),
		pos_data.get("y", 0),
		pos_data.get("z", 0)
	)

	# Create block instance
	var block := block_placer.block_palette.create_block_instance(
		block_type,
		grid_pos,
		rotation
	)

	if !block:
		push_error("[LevelSerializer] Failed to create block: %s" % block_type)
		return false

	# Load additional data
	block.load_from_data(data)

	# Add to scene
	block_placer.level_root.add_child(block)

	# Track the block
	var key := block_placer.get_grid_key(grid_pos)
	block_placer.placed_blocks[key] = block
	block_placer.blocks_by_id[block.block_id] = block

	return true


## Create an object from saved data
func create_object_from_data(data: Dictionary) -> bool:
	if !object_placer or !object_placer.object_palette:
		return false

	var object_type: String = data.get("object_type", "")
	var properties: Dictionary = data.get("properties", {})

	var pos_data: Dictionary = data.get("position", {})
	var grid_pos := Vector3(
		pos_data.get("x", 0),
		pos_data.get("y", 0),
		pos_data.get("z", 0)
	)

	# Create object instance
	var obj := object_placer.object_palette.create_object_instance(
		object_type,
		grid_pos,
		properties
	)

	if !obj:
		push_error("[LevelSerializer] Failed to create object: %s" % object_type)
		return false

	# Load additional data
	obj.load_from_data(data)

	# Add to scene
	object_placer.level_root.add_child(obj)

	# Track the object
	object_placer.placed_objects[obj.object_id] = obj

	var key := object_placer.get_grid_key(grid_pos)
	if !object_placer.objects_at_position.has(key):
		object_placer.objects_at_position[key] = []
	object_placer.objects_at_position[key].append(obj)

	return true


## Clear current level (remove all blocks and objects)
func clear_current_level() -> void:
	if block_placer:
		block_placer.clear_all_blocks()

	if object_placer:
		object_placer.clear_all_objects()

	print("[LevelSerializer] Cleared current level")


## Get list of saved level files
func get_saved_levels() -> Array[String]:
	var levels: Array[String] = []

	var dir := DirAccess.open(LEVELS_DIR)
	if !dir:
		push_error("[LevelSerializer] Failed to open levels directory")
		return levels

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if !dir.current_is_dir() and file_name.ends_with(".json"):
			levels.append(file_name)
		file_name = dir.get_next()

	dir.list_dir_end()

	levels.sort()
	return levels


## Get full path to a level file
func get_level_path(file_name: String) -> String:
	if !file_name.ends_with(".json"):
		file_name += ".json"
	return LEVELS_DIR + file_name


## Sanitize filename (remove invalid characters)
func sanitize_filename(name: String) -> String:
	var sanitized := name.strip_edges()
	sanitized = sanitized.replace(" ", "_")
	sanitized = sanitized.to_lower()

	# Remove invalid characters
	var valid_chars := "abcdefghijklmnopqrstuvwxyz0123456789_-"
	var result := ""

	for c in sanitized:
		if c in valid_chars:
			result += c

	# Ensure not empty
	if result.is_empty():
		result = "untitled_level"

	return result


## Delete a saved level
func delete_level(file_name: String) -> bool:
	var file_path := get_level_path(file_name)

	if !FileAccess.file_exists(file_path):
		push_error("[LevelSerializer] File not found: %s" % file_path)
		return false

	var dir := DirAccess.open(LEVELS_DIR)
	if !dir:
		return false

	var error := dir.remove(file_name)
	if error == OK:
		print("[LevelSerializer] Deleted level: %s" % file_name)
		return true
	else:
		push_error("[LevelSerializer] Failed to delete level: %d" % error)
		return false
