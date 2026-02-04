extends "res://scripts/interactable.gd"

## PersistentDoor - Example interactable that remembers open/closed state
##
## Uses PersistenceManager to track opened state across dimensions
## and scene reloads. Once opened, stays open.

# Unique identifier for this door (MUST be unique across entire game)
@export var door_id: String = ""

# Prompts
@export var closed_prompt: String = "Press E to open door"
@export var opened_prompt: String = "Door is open"

# Messages
@export var opening_message: String = "Door opened"

# Animation settings
@export var open_position_offset: Vector3 = Vector3(0, 2, 0)
@export var animation_duration: float = 1.0

# Node references (optional - for animating parts)
@export var door_mesh: MeshInstance3D
@export var door_collision: CollisionShape3D

var is_open: bool = false
var original_position: Vector3

func _ready():
    # Validate door_id
    if door_id.is_empty():
        push_error("PersistentDoor '%s': door_id is empty! Each door needs a unique ID." % name)
        return

    # Store original position for animation
    if door_mesh:
        original_position = door_mesh.position

    # Check if already opened
    if PersistenceManager.is_opened(door_id):
        # Door was previously opened - set to open state immediately
        _set_open_state(true, false) # true = open, false = no animation
    else:
        # Register with PersistenceManager if not already tracked
        if not PersistenceManager.has_object_state(door_id):
            PersistenceManager.register_object(door_id, {"opened": false})
        _set_open_state(false, false)

    _update_prompt()

func _interact(interactor: Node):
    if is_open:
        # Already open, show message
        _show_dialogue("The door is already open.")
        return

    # Open the door
    PersistenceManager.mark_as_opened(door_id)
    _set_open_state(true, true) # true = open, true = animate

    _show_dialogue(opening_message)
    print("PersistentDoor: '%s' opened" % door_id)

func _set_open_state(open: bool, animate: bool):
    is_open = open

    if not door_mesh:
        push_warning("PersistentDoor '%s': No door_mesh assigned" % door_id)
        return

    if animate:
        _animate_door(open)
    else:
        # Instant state change (for loading saved state)
        if is_open:
            door_mesh.position = original_position + open_position_offset
            if door_collision:
                door_collision.disabled = true
        else:
            door_mesh.position = original_position
            if door_collision:
                door_collision.disabled = false

    _update_prompt()

func _animate_door(open: bool):
    var target_position = original_position + open_position_offset if open else original_position

    var tween = create_tween()
    tween.set_ease(Tween.EASE_IN_OUT)
    tween.set_trans(Tween.TRANS_CUBIC)

    tween.tween_property(door_mesh, "position", target_position, animation_duration)

    # Disable collision when open
    if open and door_collision:
        tween.tween_callback(func(): door_collision.disabled = true)

func _update_prompt():
    if is_open:
        interaction_text = opened_prompt
    else:
        interaction_text = closed_prompt

func _show_dialogue(text: String):
    # Use the dialogue system if available
    if has_node("/root/DialogueUI"):
        get_node("/root/DialogueUI").show_dialogue(text)
    else:
        print("Door dialogue: %s" % text)
