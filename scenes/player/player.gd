# scenes/player/player.gd
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.002

@export var dimension_switch_sound: AudioStream

@onready var camera = $Camera3D
@onready var dimension_audio = $DimensionSwitchAudio

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

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
