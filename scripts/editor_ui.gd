extends Control

# Reference to the EventBus autoload
onready var EventBus = get_node("/root/EventBus")

func _ready():
    # Get the QuickTestButton node and connect its pressed signal
    $QuickTestButton.connect("pressed", self, "_on_quick_test_button_pressed")

func _on_quick_test_button_pressed():
    # Emit an event to switch to play mode at a chosen spawn point
    EventBus.emit_event("switch_to_play_mode", "spawn_point_1")
