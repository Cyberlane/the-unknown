extends Node

## DimensionManager Autoload - Manages dimension switching and state
##
## Handles dimension transitions, audio crossfading, and broadcasts dimension change events

# Signals
signal dimension_changed(from_dimension: String, to_dimension: String)

# Export variables for designer-facing parameters
@export var ambient_audio_config: Array = []

# Dictionary to hold AudioStreamPlayers
var audio_players: Dictionary = {}

# Current dimension
var current_dimension: String = "normal"


func _ready() -> void:
	# Initialize audio players for each dimension
	for config in ambient_audio_config:
		if config.has("audio_stream"):
			var audio_player = AudioStreamPlayer.new()
			audio_player.stream = load(config["audio_stream"])
			add_child(audio_player)
			audio_players[config.get("dimension", "unknown")] = audio_player


func switch_dimension(new_dimension: String) -> void:
	"""Switch to a different dimension"""
	if current_dimension == new_dimension:
		return

	var old_dimension = current_dimension
	current_dimension = new_dimension

	# Crossfade audio if configured
	_crossfade_audio(old_dimension, new_dimension)

	# Emit signal for other systems to react
	dimension_changed.emit(old_dimension, new_dimension)

	# Also broadcast via EventBus if it exists
	if has_node("/root/EventBus"):
		EventBus.dimension_changed.emit(old_dimension, new_dimension)


func _crossfade_audio(from_dim: String, to_dim: String) -> void:
	"""Crossfade ambient audio between dimensions"""
	# Fade out old dimension audio
	if audio_players.has(from_dim):
		var old_player = audio_players[from_dim]
		# TODO: Implement tween-based crossfade
		old_player.volume_db = -80  # Mute for now

	# Fade in new dimension audio
	if audio_players.has(to_dim):
		var new_player = audio_players[to_dim]
		new_player.volume_db = 0  # Full volume for now
		if not new_player.playing:
			new_player.play()


func get_current_dimension() -> String:
	"""Get the currently active dimension"""
	return current_dimension
