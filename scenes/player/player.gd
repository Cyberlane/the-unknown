# scenes/player/player.gd
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002

@export var dimension_switch_sound: AudioStream
@export var interaction_distance: float = 3.0

@onready var camera = $Camera3D
@onready var dimension_audio = $DimensionSwitchAudio
@onready var interaction_ray = $Camera3D/InteractionRay

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_interactable: Interactable = null

# Dimension-specific pitch variations for the whoosh sound
var dimension_pitches = {
    DimensionManager.Dimension.NORMAL: 1.0,    # Base pitch
    DimensionManager.Dimension.VIKING: 0.85,   # Lower, heavier
    DimensionManager.Dimension.AZTEC: 1.2,     # Higher, lighter
    DimensionManager.Dimension.NIGHTMARE: 0.7  # Lowest, ominous
}

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

    # Connect to dimension changes for audio feedback
    DimensionManager.dimension_changed.connect(_on_dimension_changed)

    # Set up audio player
    if dimension_switch_sound:
        dimension_audio.stream = dimension_switch_sound

    # Set up interaction raycast
    interaction_ray.target_position = Vector3(0, 0, -interaction_distance)

func _on_dimension_changed(new_dim):
    # Play whoosh sound with dimension-specific pitch
    if dimension_audio.stream:
        var pitch = dimension_pitches.get(new_dim, 1.0)
        dimension_audio.pitch_scale = pitch
        dimension_audio.play()

func _input(event):
    # Mouse look
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
        camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
        camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

    # ESC to release mouse
    if event.is_action_pressed("ui_cancel"):
        if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        else:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

    # Dimension switching with number keys
    if event.is_action_pressed("dimension_1"):
        DimensionManager.switch_to(0)  # NORMAL
    elif event.is_action_pressed("dimension_2"):
        DimensionManager.switch_to(1)  # VIKING
    elif event.is_action_pressed("dimension_3"):
        DimensionManager.switch_to(2)  # AZTEC
    elif event.is_action_pressed("dimension_4"):
        DimensionManager.switch_to(3)  # NIGHTMARE

    # Interaction with E key
    if event.is_action_pressed("interact"):
        _try_interact()

func _physics_process(delta):
    # Add gravity
    if not is_on_floor():
        velocity.y -= gravity * delta

    # Handle jump
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # Get input direction
    var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

    if direction:
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)

    move_and_slide()

    # Check for interactables every frame
    _check_for_interactable()

func _check_for_interactable() -> void:
    if interaction_ray.is_colliding():
        var collider = interaction_ray.get_collider()

        # Check if we hit an Interactable or a node with an Interactable parent
        var interactable = _find_interactable(collider)

        if interactable and interactable != current_interactable:
            current_interactable = interactable
            _show_interaction_prompt()
        elif not interactable and current_interactable:
            current_interactable = null
            _hide_interaction_prompt()
    else:
        if current_interactable:
            current_interactable = null
            _hide_interaction_prompt()

func _find_interactable(node: Node) -> Interactable:
    # Check if the node itself is an Interactable
    if node is Interactable:
        return node

    # Check if any parent is an Interactable
    var current = node
    while current:
        if current is Interactable:
            return current
        current = current.get_parent()

    return null

func _try_interact() -> void:
    if current_interactable:
        current_interactable.interact(self)

func _show_interaction_prompt() -> void:
    var ui = get_tree().get_first_node_in_group("interaction_ui")
    if ui and ui.has_method("show_prompt"):
        var prompt = current_interactable.get_interaction_prompt()
        ui.show_prompt(prompt)

func _hide_interaction_prompt() -> void:
    var ui = get_tree().get_first_node_in_group("interaction_ui")
    if ui and ui.has_method("hide_prompt"):
        ui.hide_prompt()
