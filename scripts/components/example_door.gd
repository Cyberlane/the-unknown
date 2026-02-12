extends SimpleInteractable
class_name ExampleDoor
## Example of a simple door that opens/closes when interacted with

@export var open_position_offset: Vector3 = Vector3(0, 2, 0)  # How far door moves when open
@export var animation_duration: float = 1.0
@export var open_sound: AudioStream = null
@export var close_sound: AudioStream = null

var is_open: bool = false
var is_animating: bool = false
var closed_position: Vector3
var open_position: Vector3

@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready() -> void:
	super._ready()  # Call parent _ready()

	# Store positions
	closed_position = position
	open_position = position + open_position_offset

	# Update prompt
	update_prompt()

	# Create audio player if it doesn't exist
	if not has_node("AudioStreamPlayer3D"):
		audio_player = AudioStreamPlayer3D.new()
		audio_player.name = "AudioStreamPlayer3D"
		add_child(audio_player)

func on_interact(_interactor: Node) -> void:
	"""Toggle door open/close"""
	if is_animating:
		return

	if is_open:
		close_door()
	else:
		open_door()

func open_door() -> void:
	"""Animate door opening"""
	if is_animating or is_open:
		return

	is_animating = true
	is_open = true
	update_prompt()

	# Play sound
	if open_sound and audio_player:
		audio_player.stream = open_sound
		audio_player.play()

	# Animate position
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", open_position, animation_duration)
	tween.finished.connect(_on_animation_finished)

	if OS.is_debug_build():
		print("Door '%s' opening" % name)

func close_door() -> void:
	"""Animate door closing"""
	if is_animating or not is_open:
		return

	is_animating = true
	is_open = false
	update_prompt()

	# Play sound
	if close_sound and audio_player:
		audio_player.stream = close_sound
		audio_player.play()

	# Animate position
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", closed_position, animation_duration)
	tween.finished.connect(_on_animation_finished)

	if OS.is_debug_build():
		print("Door '%s' closing" % name)

func _on_animation_finished() -> void:
	"""Called when door animation completes"""
	is_animating = false

func update_prompt() -> void:
	"""Update interaction prompt based on door state"""
	if is_open:
		interaction_prompt = "Press [E] to close door"
	else:
		interaction_prompt = "Press [E] to open door"
