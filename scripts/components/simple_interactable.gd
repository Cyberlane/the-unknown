extends StaticBody3D
class_name SimpleInteractable
## Base class for simple interactable objects
## Place this on objects you want the player to interact with

@export var interaction_prompt: String = "Press [E] to interact"
@export var interaction_enabled: bool = true
@export var one_time_use: bool = false

var has_been_used: bool = false

func _ready() -> void:
	# Make sure we're on the interaction layer
	collision_layer = 2  # Layer 2 for interactables
	collision_mask = 0   # Don't detect collisions

	# Add to interactables group
	add_to_group("interactables")

	if OS.is_debug_build():
		print("SimpleInteractable '%s' ready" % name)

func interact(interactor: Node) -> void:
	"""Called when player interacts with this object"""
	if not interaction_enabled:
		return

	if one_time_use and has_been_used:
		return

	# Perform interaction
	on_interact(interactor)

	# Mark as used if one-time
	if one_time_use:
		has_been_used = true
		interaction_enabled = false

		if OS.is_debug_build():
			print("'%s' has been used and is now disabled" % name)

func on_interact(_interactor: Node) -> void:
	"""Override this in child classes to define custom behavior"""
	if OS.is_debug_build():
		print("Interacted with: ", name)

func get_interaction_prompt() -> String:
	"""Returns the prompt text shown to the player"""
	return interaction_prompt

func enable_interaction() -> void:
	"""Enable interaction with this object"""
	interaction_enabled = true

func disable_interaction() -> void:
	"""Disable interaction with this object"""
	interaction_enabled = false
