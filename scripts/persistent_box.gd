extends RigidBody3D

## PersistentBox - A movable box that remembers its position across dimensions and scene reloads
##
## Uses PersistenceManager to save/restore position and rotation when pushed by player

@export var box_id: String = ""
@export var save_interval: float = 0.5  # How often to save position when moving

var last_position: Vector3
var last_rotation: Vector3
var save_timer: float = 0.0
var is_moving: bool = false

func _ready():
    # Validate box_id
    if box_id.is_empty():
        push_error("PersistentBox '%s': box_id is empty! Each box needs a unique ID." % name)
        return

    # Register with PersistenceManager if not already tracked
    if not PersistenceManager.has_object_state(box_id):
        PersistenceManager.register_object(box_id, {
            "position": global_position,
            "rotation": rotation
        })
    else:
        # Restore saved position and rotation
        _restore_state()

    last_position = global_position

    # Connect to body signals to detect when being moved
    body_entered.connect(_on_body_entered)

func _restore_state():
    var state = PersistenceManager.get_object_state(box_id)

    if state.has("position"):
        var saved_pos = state["position"]
        # Convert dictionary to Vector3 if needed
        if saved_pos is Dictionary:
            global_position = Vector3(saved_pos.x, saved_pos.y, saved_pos.z)
        else:
            global_position = saved_pos

    if state.has("rotation"):
        var saved_rot = state["rotation"]
        # Convert dictionary to Vector3 if needed
        if saved_rot is Dictionary:
            rotation = Vector3(saved_rot.x, saved_rot.y, saved_rot.z)
        else:
            rotation = saved_rot

    print("PersistentBox '%s': Restored position %s" % [box_id, global_position])

func _physics_process(delta):
    if box_id.is_empty():
        return

    # Check if box has moved
    var current_pos = global_position
    if current_pos.distance_to(last_position) > 0.01:
        is_moving = true
        last_position = current_pos
    else:
        is_moving = false

    # Save position periodically when moving
    if is_moving:
        save_timer += delta
        if save_timer >= save_interval:
            _save_state()
            save_timer = 0.0

func _save_state():
    # Save current position and rotation
    PersistenceManager.update_object_state(box_id, {
        "position": global_position,
        "rotation": rotation
    })

func _on_body_entered(body: Node):
    # When something collides, save state shortly after
    await get_tree().create_timer(0.2).timeout
    _save_state()

# Save state when box is about to be freed (scene unload)
func _exit_tree():
    if not box_id.is_empty():
        _save_state()
