extends Node

## PersistenceManager - Global state persistence system
##
## Tracks object states (collected, opened, activated, etc.) across dimensions
## and level region reloads. Objects register with a unique ID and can save/load
## their state through this singleton.

# Dictionary structure: { "unique_id": { arbitrary state data } }
var object_states: Dictionary = {}

# Signals for external systems to react to state changes
signal object_state_changed(object_id: String, new_state: Dictionary)
signal object_state_registered(object_id: String)

## Register an object with an initial state
## Returns false if ID already exists (duplicate), true on success
func register_object(object_id: String, initial_state: Dictionary = {}) -> bool:
    if object_states.has(object_id):
        push_warning("PersistenceManager: Object ID '%s' already registered" % object_id)
        return false

    object_states[object_id] = initial_state.duplicate()
    object_state_registered.emit(object_id)
    return true

## Set the state for an object (creates entry if doesn't exist)
func set_object_state(object_id: String, state: Dictionary) -> void:
    object_states[object_id] = state.duplicate()
    object_state_changed.emit(object_id, state)

## Update specific keys in an object's state without replacing entire state
func update_object_state(object_id: String, partial_state: Dictionary) -> void:
    if not object_states.has(object_id):
        object_states[object_id] = {}

    for key in partial_state.keys():
        object_states[object_id][key] = partial_state[key]

    object_state_changed.emit(object_id, object_states[object_id])

## Get the current state of an object
## Returns empty Dictionary if object not found
func get_object_state(object_id: String) -> Dictionary:
    if object_states.has(object_id):
        return object_states[object_id].duplicate()
    return {}

## Check if an object has registered state
func has_object_state(object_id: String) -> bool:
    return object_states.has(object_id)

## Get a specific property from an object's state
## Returns default_value if object or property doesn't exist
func get_object_property(object_id: String, property_name: String, default_value = null):
    if object_states.has(object_id) and object_states[object_id].has(property_name):
        return object_states[object_id][property_name]
    return default_value

## Set a specific property in an object's state
func set_object_property(object_id: String, property_name: String, value) -> void:
    if not object_states.has(object_id):
        object_states[object_id] = {}

    object_states[object_id][property_name] = value
    object_state_changed.emit(object_id, object_states[object_id])

## Clear all object states (useful for new game)
func clear_all_states() -> void:
    object_states.clear()
    print("PersistenceManager: All object states cleared")

## Remove a specific object's state
func remove_object_state(object_id: String) -> void:
    if object_states.erase(object_id):
        print("PersistenceManager: Removed state for '%s'" % object_id)

## Get all registered object IDs
func get_all_object_ids() -> Array:
    return object_states.keys()

## Debug: Print all tracked objects and their states
func debug_print_all_states() -> void:
    print("=== PersistenceManager - All Object States ===")
    if object_states.is_empty():
        print("  (No objects registered)")
    else:
        for object_id in object_states.keys():
            print("  '%s': %s" % [object_id, object_states[object_id]])
    print("==============================================")

## Save all object states to a file
## Returns true on success, false on failure
func save_to_file(filepath: String = "user://object_states.save") -> bool:
    var file = FileAccess.open(filepath, FileAccess.WRITE)
    if file == null:
        push_error("PersistenceManager: Failed to open file for writing: %s" % filepath)
        return false

    var json_string = JSON.stringify(object_states, "\t")
    file.store_string(json_string)
    file.close()

    print("PersistenceManager: Saved %d object states to %s" % [object_states.size(), filepath])
    return true

## Load all object states from a file
## Returns true on success, false on failure
func load_from_file(filepath: String = "user://object_states.save") -> bool:
    if not FileAccess.file_exists(filepath):
        push_warning("PersistenceManager: Save file not found: %s" % filepath)
        return false

    var file = FileAccess.open(filepath, FileAccess.READ)
    if file == null:
        push_error("PersistenceManager: Failed to open file for reading: %s" % filepath)
        return false

    var json_string = file.get_as_text()
    file.close()

    var json = JSON.new()
    var parse_result = json.parse(json_string)

    if parse_result != OK:
        push_error("PersistenceManager: Failed to parse JSON from save file")
        return false

    var loaded_data = json.get_data()
    if typeof(loaded_data) != TYPE_DICTIONARY:
        push_error("PersistenceManager: Save file data is not a Dictionary")
        return false

    object_states = loaded_data
    print("PersistenceManager: Loaded %d object states from %s" % [object_states.size(), filepath])
    return true

## Common helper: Mark an object as collected/picked up
func mark_as_collected(object_id: String) -> void:
    set_object_property(object_id, "collected", true)
    set_object_property(object_id, "collected_at", Time.get_unix_time_from_system())

## Common helper: Check if an object is collected
func is_collected(object_id: String) -> bool:
    return get_object_property(object_id, "collected", false)

## Common helper: Mark a door/chest as opened
func mark_as_opened(object_id: String) -> void:
    set_object_property(object_id, "opened", true)
    set_object_property(object_id, "opened_at", Time.get_unix_time_from_system())

## Common helper: Check if a door/chest is opened
func is_opened(object_id: String) -> bool:
    return get_object_property(object_id, "opened", false)

## Common helper: Mark a switch/lever as activated
func mark_as_activated(object_id: String) -> void:
    set_object_property(object_id, "activated", true)
    set_object_property(object_id, "activated_at", Time.get_unix_time_from_system())

## Common helper: Check if a switch/lever is activated
func is_activated(object_id: String) -> bool:
    return get_object_property(object_id, "activated", false)
