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
            listener.call_func(*args)
