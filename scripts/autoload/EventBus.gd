# EventBus autoload singleton  (signal-based communication hub)
extends Node2D

var _event_listeners = {}

func emit(event, data):
    if not _event_listeners[event]:
        return
    for listener in _event_listeners[event]:
        listener.notify(data)

func connect(event, callback):
    if not _event_listeners[event]:
         _event_listeners[event] = []
    _event_listeners[event].append(callback)
