extends SimpleInteractable
class_name PickupItem
## Example pickup item that can be collected by the player
## Extends SimpleInteractable to demonstrate the interaction system

@export_group("Pickup Settings")
@export var item_name: String = "Item"
@export var pickup_sound: AudioStream
@export var auto_destroy_on_pickup: bool = true
@export var float_amplitude: float = 0.2
@export var float_speed: float = 2.0
@export var rotate_speed: float = 90.0  # Degrees per second

var initial_y: float = 0.0
var time: float = 0.0

func _ready() -> void:
	super._ready()  # Call parent ready
	initial_y = global_position.y

	# Set the interaction prompt with the item name
	interaction_prompt = "Press [E] to pick up %s" % item_name

	if OS.is_debug_build():
		print("PickupItem '%s' ready at position %s" % [item_name, global_position])

func _process(delta: float) -> void:
	if not has_been_used:
		time += delta

		# Float up and down
		if float_amplitude > 0:
			var offset = sin(time * float_speed) * float_amplitude
			global_position.y = initial_y + offset

		# Rotate
		if rotate_speed > 0:
			rotate_y(deg_to_rad(rotate_speed) * delta)

func on_interact(interactor: Node) -> void:
	"""Override from SimpleInteractable - called when player interacts"""
	if OS.is_debug_build():
		print("Player picked up: %s" % item_name)

	# Emit pickup event
	EventBus.item_picked_up.emit(item_name, get_item_data())

	# Play pickup sound if available
	if pickup_sound:
		play_pickup_sound()

	# Destroy or disable based on settings
	if auto_destroy_on_pickup:
		queue_free()
	else:
		# Just hide and disable
		visible = false
		interaction_enabled = false

func get_item_data() -> Dictionary:
	"""Returns a dictionary with item information"""
	return {
		"name": item_name,
		"position": global_position,
		"timestamp": Time.get_ticks_msec()
	}

func play_pickup_sound() -> void:
	"""Play pickup sound (detached so it plays even after item is destroyed)"""
	if not pickup_sound:
		return

	# Create a one-shot audio player
	var audio_player = AudioStreamPlayer3D.new()
	audio_player.stream = pickup_sound
	audio_player.bus = "SFX"
	audio_player.max_distance = 10.0

	# Add to scene root so it persists after item is destroyed
	get_tree().root.add_child(audio_player)
	audio_player.global_position = global_position

	# Play and auto-destroy when finished
	audio_player.play()
	audio_player.finished.connect(func(): audio_player.queue_free())
