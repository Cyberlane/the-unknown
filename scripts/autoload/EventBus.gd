extends Node

class_name EventBus

signal event_received(event: String, data)

func emit_event(event: String, data := null):
    emit_signal("event_received", event, data)
