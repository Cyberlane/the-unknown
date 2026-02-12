extends Camera3D
## Free-fly camera for editor mode with smooth movement and grid snapping

# Movement settings
@export var base_speed: float = 10.0
@export var fast_multiplier: float = 3.0
@export var slow_multiplier: float = 0.3
@export var acceleration: float = 10.0
@export var friction: float = 8.0

# Mouse look settings
@export var mouse_sensitivity: float = 0.003
@export var look_enabled_on_right_click: bool = true

# Internal state
var velocity: Vector3 = Vector3.ZERO
var rotation_x: float = 0.0
var rotation_y: float = 0.0
var is_looking: bool = false
var was_mouse_captured: bool = false


func _ready() -> void:
	# Register with EditorMode
	EditorMode.editor_camera = self

	# Start disabled
	set_process_mode(Node.PROCESS_MODE_DISABLED)
	current = false
	visible = false

	# Initialize rotation from current transform
	rotation_x = rotation.x
	rotation_y = rotation.y


func _input(event: InputEvent) -> void:
	if !EditorMode.editor_active:
		return

	# Handle right-click for mouse look
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				start_looking()
			else:
				stop_looking()

	# Handle mouse motion for camera rotation
	if event is InputEventMouseMotion and is_looking:
		rotate_camera(event.relative)

	# Toggle grid visibility
	if event.is_action_pressed("ui_accept"):  # G key
		if event.keycode == KEY_G:
			EditorMode.toggle_grid_visibility()


func _process(delta: float) -> void:
	if !EditorMode.editor_active:
		return

	handle_movement(delta)


## Handle WASD movement and Q/E for up/down
func handle_movement(delta: float) -> void:
	# Get input direction
	var input_dir := Vector3.ZERO

	# WASD for horizontal movement
	if Input.is_action_pressed("move_forward"):
		input_dir -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		input_dir += transform.basis.z
	if Input.is_action_pressed("move_left"):
		input_dir -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		input_dir += transform.basis.x

	# Q/E for vertical movement
	if Input.is_key_pressed(KEY_Q):
		input_dir.y -= 1.0
	if Input.is_key_pressed(KEY_E):
		input_dir.y += 1.0

	# Normalize to prevent faster diagonal movement
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()

	# Calculate target velocity with speed modifiers
	var current_speed := base_speed

	if Input.is_action_pressed("sprint"):  # Shift
		current_speed *= fast_multiplier
	elif Input.is_action_pressed("crouch"):  # Ctrl
		current_speed *= slow_multiplier

	var target_velocity := input_dir * current_speed

	# Smooth acceleration/deceleration
	if target_velocity.length() > 0:
		velocity = velocity.lerp(target_velocity, acceleration * delta)
	else:
		velocity = velocity.lerp(Vector3.ZERO, friction * delta)

	# Apply movement
	global_position += velocity * delta


## Start mouse look mode
func start_looking() -> void:
	is_looking = true
	was_mouse_captured = Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


## Stop mouse look mode
func stop_looking() -> void:
	is_looking = false
	if !was_mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


## Rotate camera based on mouse movement
func rotate_camera(relative: Vector2) -> void:
	# Horizontal rotation (Y-axis)
	rotation_y -= relative.x * mouse_sensitivity

	# Vertical rotation (X-axis) with clamping
	rotation_x -= relative.y * mouse_sensitivity
	rotation_x = clamp(rotation_x, -PI / 2.0, PI / 2.0)

	# Apply rotations
	rotation.x = rotation_x
	rotation.y = rotation_y


## Get camera position snapped to grid
func get_snapped_position() -> Vector3:
	return EditorMode.snap_position_to_grid(global_position)
