extends CharacterBody3D

# Export variables for designer-facing parameters
export var movement_speed: float = 5.0
export var sprint_multiplier: float = 2.0
export var crouch_multiplier: float = 0.5
export var head_bob_amplitude: float = 0.1
export var head_bob_frequency: float = 8.0

# Internal variables
var camera: Camera3D
var movement_config: Resource
var velocity: Vector3 = Vector3.ZERO
var is_sprinting: bool = false
var is_crouching: bool = false
var head_bob_offset: float = 0.0

func _ready():
    camera = $Camera3D
    set_process(true)

func _process(delta):
    handle_input(delta)
    move_and_slide(velocity, Vector3.UP)
    apply_head_bob(delta)

func handle_input(delta):
    var direction = Vector3.ZERO

    if Input.is_action_pressed("ui_right"):
        direction.x += 1
    if Input.is_action_pressed("ui_left"):
        direction.x -= 1
    if Input.is_action_pressed("ui_down"):
        direction.z += 1
    if Input.is_action_pressed("ui_up"):
        direction.z -= 1

    direction = direction.normalized()

    # Determine the speed multiplier based on sprinting or crouching
    var speed_multiplier = is_sprinting ? sprint_multiplier : (is_crouching ? crouch_multiplier : 1.0)
    velocity = direction * movement_speed * speed_multiplier * delta

    handle_mouse_look(delta)

func handle_mouse_look(delta):
    const sensitivity: float = 0.5
    var mouse_motion = Input.get_mouse_motion()
    camera.rotation.y += mouse_motion.x * sensitivity * delta
    camera.rotation.x -= mouse_motion.y * sensitivity * delta
    camera.rotation.x = clamp(camera.rotation.x, -PI / 2, PI / 2)

func apply_head_bob(delta):
    head_bob_offset += head_bob_frequency * delta
    var bob_height = sin(head_bob_offset) * head_bob_amplitude
    camera.transform.origin.y = 1.6 + bob_height

func _input(event):
    if event is InputEventKey:
        if event.pressed:
            if event.scancode == KEY_LSHIFT:
                is_sprinting = true
            elif event.scancode == KEY_C:
                is_crouching = true
        else:
            if event.scancode == KEY_LSHIFT:
                is_sprinting = false
            elif event.scancode == KEY_C:
                is_crouching = false
