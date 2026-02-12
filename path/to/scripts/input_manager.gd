extends Node

@export var dimension_keys: Array = [Key.KEY_1, Key.KEY_2, Key.KEY_3, Key.KEY_4]

func _ready():
    set_process_input(true)

func _input(event):
    if event is InputEventKey and event.pressed:
        for i in range(dimension_keys.size()):
            if event.scancode == dimension_keys[i]:
                EventBus.emit_signal("dimension_toggle", i + 1)
