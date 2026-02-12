extends CharacterBody3D

# Export variables for designer-facing parameters
export(float) var sanity_threshold = 0.5
export(NodePath) var stinger_sound_config_path = "res://assets/configs/stinger_sound_config.tres"

# Reference to the EventBus autoload
onready var event_bus = get_node("/root/EventBus")

# Reference to the stinger sound configuration resource
var stinger_sound_config: Resource

func _ready():
    # Load the stinger sound configuration resource
    stinger_sound_config = load(stinger_sound_config_path)
    
    # Subscribe to sanity events
    event_bus.add_listener("sanity_event", _on_sanity_event)

func _on_sanity_event(sanity_level: float):
    if sanity_level <= sanity_threshold:
        # Play the stinger sound
        play_stinger_sound()

func play_stinger_sound():
    var stinger_sound = stinger_sound_config.stinger_sound
    if stinger_sound:
        stinger_sound.play()
