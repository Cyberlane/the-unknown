extends CharacterBody3D
class_name FirstPersonController
## First-person player controller with movement, look, sprint, crouch, and head bob

# ===== NODES =====
@onready var camera: Camera3D = $Camera3D
@onready var head_bob_timer: float = 0.0

# ===== MOVEMENT SETTINGS =====
@export_group("Movement")
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var crouch_speed: float = 2.5
@export var acceleration: float = 10.0
@export var deceleration: float = 12.0
@export var air_acceleration: float = 5.0
@export var jump_velocity: float = 4.5

# ===== CROUCH SETTINGS =====
@export_group("Crouch")
@export var crouch_depth: float = 0.5  # How much the camera lowers
@export var crouch_transition_speed: float = 10.0
var is_crouching: bool = false
var standing_camera_y: float = 0.0  # Set in _ready()
var crouching_camera_y: float = 0.0

# ===== MOUSE LOOK SETTINGS =====
@export_group("Mouse Look")
@export var mouse_sensitivity: float = 0.003
@export var mouse_invert_y: bool = false
@export var max_look_angle: float = 89.0  # Prevent full vertical rotation

# ===== HEAD BOB SETTINGS =====
@export_group("Head Bob")
@export var head_bob_enabled: bool = true
@export var head_bob_frequency: float = 2.0  # Steps per second
@export var head_bob_amplitude: float = 0.08  # How much the camera moves
@export var head_bob_lerp_speed: float = 10.0
var head_bob_offset: Vector3 = Vector3.ZERO

# ===== STATE =====
var current_speed: float = walk_speed
var is_sprinting: bool = false
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_rotation_x: float = 0.0

# ===== DEBUG =====
var debug_enabled: bool = true

func _ready() -> void:
	# Register with EditorMode
	EditorMode.player_controller = self

	# Capture mouse (unless editor is active)
	if !EditorMode.editor_active:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Store standing camera position
	if camera:
		standing_camera_y = camera.position.y
		crouching_camera_y = standing_camera_y - crouch_depth
	else:
		push_error("FirstPersonController: Camera3D node not found!")

	# Emit ready signal
	EventBus.player_state_changed.emit("idle")

	if debug_enabled:
		print("FirstPersonController initialized")

func _unhandled_input(event: InputEvent) -> void:
	# Don't process input if editor is active
	if EditorMode.editor_active:
		return

	# Mouse look
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		handle_mouse_look(event)

	# Toggle mouse capture (for debugging)
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	# Don't process physics if editor is active
	if EditorMode.editor_active:
		return

	handle_crouch(delta)
	handle_movement(delta)
	handle_head_bob(delta)

	# Emit position for any listeners (minimap, save system, etc.)
	EventBus.player_position_changed.emit(global_position)

func handle_mouse_look(event: InputEventMouseMotion) -> void:
	if not camera:
		return

	# Rotate player body horizontally
	rotate_y(-event.relative.x * mouse_sensitivity)

	# Rotate camera vertically with clamping
	var vertical_delta = event.relative.y * mouse_sensitivity
	if mouse_invert_y:
		vertical_delta = -vertical_delta

	camera_rotation_x += vertical_delta
	camera_rotation_x = clamp(camera_rotation_x, -deg_to_rad(max_look_angle), deg_to_rad(max_look_angle))
	camera.rotation.x = camera_rotation_x

func handle_crouch(delta: float) -> void:
	if not camera:
		return

	# Toggle crouch
	if Input.is_action_just_pressed("crouch"):
		is_crouching = !is_crouching

	# Smoothly transition camera height
	var target_y = crouching_camera_y if is_crouching else standing_camera_y
	camera.position.y = lerp(camera.position.y, target_y, crouch_transition_speed * delta)

func handle_movement(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get input direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Determine current speed (sprint only if moving forward and on ground)
	if Input.is_action_pressed("sprint") and is_on_floor() and not is_crouching and input_dir.y < 0:
		current_speed = sprint_speed
		is_sprinting = true
	elif is_crouching:
		current_speed = crouch_speed
		is_sprinting = false
	else:
		current_speed = walk_speed
		is_sprinting = false

	# Apply acceleration/deceleration
	var target_velocity = direction * current_speed
	var accel = acceleration if is_on_floor() else air_acceleration

	if direction:
		velocity.x = lerp(velocity.x, target_velocity.x, accel * delta)
		velocity.z = lerp(velocity.z, target_velocity.z, accel * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, deceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, deceleration * delta)

	move_and_slide()

func handle_head_bob(delta: float) -> void:
	if not camera or not head_bob_enabled:
		return

	# Only bob when moving on ground
	var horizontal_velocity = Vector2(velocity.x, velocity.z).length()

	if is_on_floor() and horizontal_velocity > 0.5:
		# Increase timer based on speed
		var frequency_modifier = 1.0
		if is_sprinting:
			frequency_modifier = 1.3
		elif is_crouching:
			frequency_modifier = 0.7

		head_bob_timer += delta * head_bob_frequency * frequency_modifier

		# Calculate bob offset (figure-eight pattern)
		var bob_offset_y = sin(head_bob_timer * 2.0) * head_bob_amplitude
		var bob_offset_x = cos(head_bob_timer) * head_bob_amplitude * 0.5

		head_bob_offset = Vector3(bob_offset_x, bob_offset_y, 0)
	else:
		# Return to center when not moving
		head_bob_offset = head_bob_offset.lerp(Vector3.ZERO, head_bob_lerp_speed * delta)

	# Apply head bob to camera (additive to crouch position)
	var base_y = crouching_camera_y if is_crouching else standing_camera_y
	camera.position = Vector3(head_bob_offset.x, base_y, 0) + Vector3(0, head_bob_offset.y, 0)

func get_look_direction() -> Vector3:
	"""Returns the forward direction the camera is looking"""
	if camera:
		return -camera.global_transform.basis.z
	return -global_transform.basis.z

func get_camera_position() -> Vector3:
	"""Returns the global position of the camera for raycasting"""
	if camera:
		return camera.global_position
	return global_position

# ===== DEBUG FUNCTIONS =====
func get_debug_info() -> Dictionary:
	"""Returns dictionary of debug information for the debug overlay"""
	return {
		"position": global_position,
		"velocity": velocity,
		"speed": Vector2(velocity.x, velocity.z).length(),
		"is_on_floor": is_on_floor(),
		"is_crouching": is_crouching,
		"is_sprinting": is_sprinting,
		"current_speed": current_speed,
	}
