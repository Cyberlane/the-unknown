extends RayCast3D
class_name InteractionRaycast
## Raycast-based interaction system for first-person controller
## Detects interactable objects in front of the player

@export var interaction_distance: float = 3.0
@export var interaction_layer: int = 2  # Collision layer for interactables

var current_interactable: Node = null
var player_controller: FirstPersonController = null

func _ready() -> void:
	# Configure raycast
	target_position = Vector3(0, 0, -interaction_distance)
	collision_mask = 1 << (interaction_layer - 1)  # Only check interaction layer
	enabled = true

	# Find player controller
	player_controller = get_parent() as FirstPersonController
	if not player_controller:
		push_error("InteractionRaycast: Parent must be a FirstPersonController!")

	if OS.is_debug_build():
		print("InteractionRaycast initialized with distance: ", interaction_distance)

func _process(_delta: float) -> void:
	check_for_interactable()
	handle_interaction_input()

func check_for_interactable() -> void:
	"""Check if we're looking at an interactable object"""
	var previous_interactable = current_interactable

	if is_colliding():
		var collider = get_collider()

		# Check if the collider is an interactable (has interact method)
		if collider and collider.has_method("interact"):
			current_interactable = collider

			# Show interaction prompt if this is a new object
			if current_interactable != previous_interactable:
				show_interaction_prompt(current_interactable)
		else:
			clear_interactable()
	else:
		clear_interactable()

func clear_interactable() -> void:
	"""Clear current interactable and hide prompt"""
	if current_interactable:
		current_interactable = null
		EventBus.interactable_unfocused.emit(current_interactable)
		EventBus.interaction_prompt_hidden.emit()

func show_interaction_prompt(interactable: Node) -> void:
	"""Show interaction prompt for the given interactable"""
	EventBus.interactable_focused.emit(interactable)

	# Get custom prompt text if available
	var prompt_text = "Press [E] to interact"
	if interactable.has_method("get_interaction_prompt"):
		prompt_text = interactable.get_interaction_prompt()

	EventBus.interaction_prompt_shown.emit(prompt_text)

func handle_interaction_input() -> void:
	"""Handle interaction key press"""
	if Input.is_action_just_pressed("interact") and current_interactable:
		perform_interaction()

func perform_interaction() -> void:
	"""Perform interaction with current interactable"""
	if not current_interactable:
		return

	# Call the interact method
	if current_interactable.has_method("interact"):
		current_interactable.interact(player_controller)
		EventBus.interaction_performed.emit(current_interactable)

		if OS.is_debug_build():
			print("Interacted with: ", current_interactable.name)

func get_look_target_position() -> Vector3:
	"""Returns the position the raycast is hitting, or max distance if not hitting"""
	if is_colliding():
		return get_collision_point()
	else:
		return global_position + (-global_transform.basis.z * interaction_distance)
