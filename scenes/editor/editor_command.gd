extends RefCounted
class_name EditorCommand
## Base class for all editor commands (undo/redo pattern)

var description: String = "Command"
var timestamp: float = 0.0


func _init() -> void:
	timestamp = Time.get_ticks_msec() / 1000.0


## Execute the command (do the action)
func execute() -> void:
	push_error("[EditorCommand] execute() must be overridden")


## Undo the command (reverse the action)
func undo() -> void:
	push_error("[EditorCommand] undo() must be overridden")


## Get a display-friendly description of this command
func get_description() -> String:
	return description
