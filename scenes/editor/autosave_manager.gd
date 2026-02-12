extends Node
class_name AutosaveManager
## Manages automatic saving and dirty flag detection

signal autosave_triggered()
signal dirty_state_changed(is_dirty: bool)

@export var autosave_enabled: bool = true
@export var autosave_interval: float = 300.0  # 5 minutes in seconds
@export var autosave_filename: String = "autosave.json"

var level_serializer: LevelSerializer = null
var is_dirty: bool = false
var autosave_timer: Timer = null
var last_block_count: int = 0
var last_object_count: int = 0


func _ready() -> void:
	# Create autosave timer
	autosave_timer = Timer.new()
	autosave_timer.wait_time = autosave_interval
	autosave_timer.one_shot = false
	autosave_timer.timeout.connect(_on_autosave_timer_timeout)
	add_child(autosave_timer)

	if autosave_enabled:
		autosave_timer.start()
		print("[AutosaveManager] Autosave enabled (every %.0f seconds)" % autosave_interval)

	# Connect to EventBus signals
	EventBus.block_placed.connect(_on_level_modified)
	EventBus.block_deleted.connect(_on_level_modified.bind("", Vector3.ZERO))


## Start autosave timer
func start_autosave() -> void:
	autosave_enabled = true
	autosave_timer.start()
	print("[AutosaveManager] Autosave started")


## Stop autosave timer
func stop_autosave() -> void:
	autosave_enabled = false
	autosave_timer.stop()
	print("[AutosaveManager] Autosave stopped")


## Autosave timer timeout
func _on_autosave_timer_timeout() -> void:
	if !autosave_enabled or !is_dirty:
		return

	perform_autosave()


## Perform autosave
func perform_autosave() -> void:
	if !level_serializer:
		return

	print("[AutosaveManager] Performing autosave...")

	# Serialize level
	var level_data := level_serializer.serialize_level("Autosave", {
		"author": "Autosave",
		"description": "Automatic backup"
	})

	# Save to autosave file
	var success := level_serializer.save_level_to_file(level_data, autosave_filename)

	if success:
		print("[AutosaveManager] Autosave successful")
		autosave_triggered.emit()
		# Don't clear dirty flag - autosave is just a backup
	else:
		print("[AutosaveManager] Autosave failed")


## Mark level as modified (dirty)
func mark_dirty() -> void:
	if !is_dirty:
		is_dirty = true
		dirty_state_changed.emit(true)
		print("[AutosaveManager] Level marked as dirty")


## Clear dirty flag (e.g., after save)
func clear_dirty() -> void:
	if is_dirty:
		is_dirty = false
		dirty_state_changed.emit(false)
		print("[AutosaveManager] Level marked as clean")


## Callback when level is modified
func _on_level_modified(_type: String = "", _position: Vector3 = Vector3.ZERO) -> void:
	mark_dirty()


## Check if there are unsaved changes
func has_unsaved_changes() -> bool:
	return is_dirty


## Load autosave if it exists
func load_autosave() -> bool:
	if !level_serializer:
		return false

	var autosave_path := level_serializer.get_level_path(autosave_filename)

	if !FileAccess.file_exists(autosave_path):
		print("[AutosaveManager] No autosave found")
		return false

	print("[AutosaveManager] Loading autosave...")

	var level_data := level_serializer.load_level_from_file(autosave_path)
	if !level_data:
		return false

	var success := level_serializer.build_level_from_data(level_data)

	if success:
		print("[AutosaveManager] Autosave loaded successfully")
		mark_dirty()  # Mark as dirty since it's from autosave
		return true
	else:
		print("[AutosaveManager] Failed to load autosave")
		return false


## Delete autosave file
func delete_autosave() -> void:
	if level_serializer:
		level_serializer.delete_level(autosave_filename)
		print("[AutosaveManager] Autosave deleted")
