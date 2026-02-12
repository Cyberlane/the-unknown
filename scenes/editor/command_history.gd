extends Node
class_name CommandHistory
## Manages undo/redo command history

signal history_changed()
signal command_executed(command: EditorCommand)

@export var max_history: int = 100

var undo_stack: Array[EditorCommand] = []
var redo_stack: Array[EditorCommand] = []


func _ready() -> void:
	print("[CommandHistory] Initialized with max history: %d" % max_history)


func _input(event: InputEvent) -> void:
	if !EditorMode.editor_active:
		return

	# Undo (Ctrl+Z)
	if event.is_action_pressed("ui_undo"):
		undo()
		get_viewport().set_input_as_handled()

	# Redo (Ctrl+Y or Ctrl+Shift+Z)
	if event.is_action_pressed("ui_redo"):
		redo()
		get_viewport().set_input_as_handled()


## Execute a command and add it to history
func execute_command(command: EditorCommand) -> void:
	if !command:
		return

	# Execute the command
	command.execute()

	# Add to undo stack
	undo_stack.append(command)

	# Limit stack size
	if undo_stack.size() > max_history:
		undo_stack.pop_front()

	# Clear redo stack (new action invalidates redo)
	redo_stack.clear()

	# Emit signals
	command_executed.emit(command)
	history_changed.emit()

	print("[CommandHistory] Executed: %s" % command.get_description())


## Undo the last command
func undo() -> void:
	if undo_stack.is_empty():
		print("[CommandHistory] Nothing to undo")
		return

	var command := undo_stack.pop_back()
	command.undo()

	# Add to redo stack
	redo_stack.append(command)

	# Limit redo stack size
	if redo_stack.size() > max_history:
		redo_stack.pop_front()

	history_changed.emit()

	print("[CommandHistory] Undone: %s" % command.get_description())


## Redo the last undone command
func redo() -> void:
	if redo_stack.is_empty():
		print("[CommandHistory] Nothing to redo")
		return

	var command := redo_stack.pop_back()
	command.execute()

	# Add back to undo stack
	undo_stack.append(command)

	history_changed.emit()

	print("[CommandHistory] Redone: %s" % command.get_description())


## Clear all history
func clear_history() -> void:
	undo_stack.clear()
	redo_stack.clear()
	history_changed.emit()
	print("[CommandHistory] History cleared")


## Check if undo is available
func can_undo() -> bool:
	return !undo_stack.is_empty()


## Check if redo is available
func can_redo() -> bool:
	return !redo_stack.is_empty()


## Get last command description
func get_last_command_description() -> String:
	if undo_stack.is_empty():
		return ""
	return undo_stack.back().get_description()


## Get recent command history (for display)
func get_recent_history(count: int = 10) -> Array[String]:
	var history: Array[String] = []
	var start_index := max(0, undo_stack.size() - count)

	for i in range(start_index, undo_stack.size()):
		history.append(undo_stack[i].get_description())

	return history
