extends Node

# Reference to the EventBus autoload
onready var EventBus = get_node("/root/EventBus")

func _ready():
    # Add a listener for the start_game event
    EventBus.add_listener("start_game", self._on_start_game)

func _on_start_game(spawn_point: String):
    # Switch to play mode at the specified spawn point
    print("Starting game at spawn point:", spawn_point)
    # Add code here to switch to play mode and handle the spawn point
