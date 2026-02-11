extends Node

class_name EventBus

# Signal emitted when an event is received
signal event_received(event: String, data)

# Function to emit an event
func emit_event(event: String, data := null):
    # Emit the 'event_received' signal with the provided event and data
    emit_signal("event_received", event, data)
