extends Node

# Export variables for designer-facing parameters
export(Array) var ambient_audio_config: Array = []

# Dictionary to hold AudioStreamPlayers
var audio_players: Dictionary = {}

# Current dimension
var current_dimension: String = ""

# EventBus reference
onready var event_bus = get_node("/root/EventBus")

func _ready():
    # Initialize audio players for each dimension
    for config in ambient_audio_config:
        var audio_player = AudioStreamPlayer.new()
        audio_player.stream = preload(config["audio_stream"])
        add_child(audio_player)
        audio_players[config["dimension"]] = audio_player

    # Subscribe to dimension change events
    event_bus.connect("dimension_changed", self, "_on_dimension_changed")

func _on_dimension_changed(new_dimension: String):
    if current_dimension != "":
        # Fade out the current dimension's audio
        var current_audio_player = audio_players[current_dimension]
        current_audio_player.tween_property(current_audio_player, "volume_db", -80.0, 1.0)
    
    # Set the new dimension as current
    current_dimension = new_dimension
    
    if current_dimension != "":
        # Fade in the new dimension's audio
        var new_audio_player = audio_players[current_dimension]
        new_audio_player.volume_db = -80.0
        new_audio_player.tween_property(new_audio_player, "volume_db", 0.0, 1.0)
        new_audio_player.play()

func _on_exit_tree():
    # Unsubscribe from dimension change events
    event_bus.disconnect("dimension_changed", self, "_on_dimension_changed")
