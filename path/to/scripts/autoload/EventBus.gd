extends Node

# Dictionary to hold event listeners
var _listeners = {}

func add_listener(event_name: String, callback: Callable):
    if event_name not in _listeners:
        _listeners[event_name] = []
    _listeners[event_name].append(callback)

func remove_listener(event_name: String, callback: Callable):
    if event_name in _listeners:
        _listeners[event_name].erase(callback)
        if _listeners[event_name].size() == 0:
            _listeners.erase(event_name)

func emit_event(event_name: String, *args):
    if event_name in _listeners:
        for listener in _listeners[event_name]:
            listener.call(*args)  # Corrected method call

# New function to handle switching to play mode and returning to editor
func switch_to_play_mode(spawn_point: String):
    # Emit an event to start the game at the specified spawn point
    emit_event("start_game", spawn_point)
    
    # Wait for a short period to simulate gameplay
    yield(get_tree().create_timer(5.0), "timeout")
    
    # Return to editor mode
    get_tree().change_scene_to_file("res://scenes/editor_ui.tscn")
