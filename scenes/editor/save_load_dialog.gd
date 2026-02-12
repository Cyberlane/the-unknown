extends PanelContainer
class_name SaveLoadDialog
## UI dialog for saving and loading levels

signal level_saved(file_name: String)
signal level_loaded(file_name: String)

enum Mode {
	SAVE,
	LOAD
}

var current_mode: Mode = Mode.SAVE
var level_serializer: LevelSerializer = null

# UI nodes (created programmatically)
var title_label: Label
var level_name_input: LineEdit
var author_input: LineEdit
var description_input: TextEdit
var levels_list: ItemList
var save_button: Button
var load_button: Button
var delete_button: Button
var cancel_button: Button


func _ready() -> void:
	visible = false
	create_ui()


## Create the UI programmatically
func create_ui() -> void:
	custom_minimum_size = Vector2(500, 400)

	# Main container
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	# Title
	title_label = Label.new()
	title_label.text = "Save Level"
	title_label.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title_label)

	# Separator
	var sep1 := HSeparator.new()
	vbox.add_child(sep1)

	# Level name input
	var name_label := Label.new()
	name_label.text = "Level Name:"
	vbox.add_child(name_label)

	level_name_input = LineEdit.new()
	level_name_input.placeholder_text = "Enter level name"
	vbox.add_child(level_name_input)

	# Author input
	var author_label := Label.new()
	author_label.text = "Author (optional):"
	vbox.add_child(author_label)

	author_input = LineEdit.new()
	author_input.placeholder_text = "Your name"
	vbox.add_child(author_input)

	# Description input
	var desc_label := Label.new()
	desc_label.text = "Description (optional):"
	vbox.add_child(desc_label)

	description_input = TextEdit.new()
	description_input.placeholder_text = "Brief description of the level"
	description_input.custom_minimum_size = Vector2(0, 80)
	vbox.add_child(description_input)

	# Levels list (for loading)
	var list_label := Label.new()
	list_label.text = "Saved Levels:"
	vbox.add_child(list_label)

	levels_list = ItemList.new()
	levels_list.custom_minimum_size = Vector2(0, 150)
	levels_list.item_selected.connect(_on_level_selected)
	vbox.add_child(levels_list)

	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer)

	# Button container
	var button_hbox := HBoxContainer.new()
	button_hbox.add_theme_constant_override("separation", 10)
	vbox.add_child(button_hbox)

	# Delete button
	delete_button = Button.new()
	delete_button.text = "Delete"
	delete_button.pressed.connect(_on_delete_pressed)
	button_hbox.add_child(delete_button)

	# Spacer
	var button_spacer := Control.new()
	button_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_hbox.add_child(button_spacer)

	# Cancel button
	cancel_button = Button.new()
	cancel_button.text = "Cancel"
	cancel_button.pressed.connect(_on_cancel_pressed)
	button_hbox.add_child(cancel_button)

	# Save button
	save_button = Button.new()
	save_button.text = "Save"
	save_button.pressed.connect(_on_save_pressed)
	button_hbox.add_child(save_button)

	# Load button
	load_button = Button.new()
	load_button.text = "Load"
	load_button.pressed.connect(_on_load_pressed)
	button_hbox.add_child(load_button)


## Open dialog in save mode
func open_save_dialog(current_level_name: String = "") -> void:
	current_mode = Mode.SAVE
	title_label.text = "Save Level"

	# Show input fields
	level_name_input.visible = true
	level_name_input.editable = true
	author_input.visible = true
	description_input.visible = true

	# Show/hide buttons
	save_button.visible = true
	load_button.visible = false
	delete_button.visible = false

	# Set current name
	if !current_level_name.is_empty():
		level_name_input.text = current_level_name

	# Populate levels list for reference
	populate_levels_list()

	# Show dialog
	visible = true
	position = (get_viewport().get_visible_rect().size - size) / 2
	level_name_input.grab_focus()


## Open dialog in load mode
func open_load_dialog() -> void:
	current_mode = Mode.LOAD
	title_label.text = "Load Level"

	# Hide input fields (except name for display)
	level_name_input.visible = true
	level_name_input.editable = false
	author_input.visible = false
	description_input.visible = false

	# Show/hide buttons
	save_button.visible = false
	load_button.visible = true
	delete_button.visible = true

	# Populate levels list
	populate_levels_list()

	# Show dialog
	visible = true
	position = (get_viewport().get_visible_rect().size - size) / 2
	levels_list.grab_focus()


## Populate the levels list
func populate_levels_list() -> void:
	levels_list.clear()

	if !level_serializer:
		return

	var saved_levels := level_serializer.get_saved_levels()

	for level_file in saved_levels:
		# Load level data to show info
		var level_path := level_serializer.get_level_path(level_file)
		var level_data := level_serializer.load_level_from_file(level_path)

		if level_data:
			var display_text := "%s (%d blocks, %d objects)" % [
				level_data.level_name,
				level_data.blocks.size(),
				level_data.objects.size()
			]
			levels_list.add_item(display_text)
			levels_list.set_item_metadata(levels_list.item_count - 1, level_file)


## Callback when level is selected from list
func _on_level_selected(index: int) -> void:
	var level_file: String = levels_list.get_item_metadata(index)
	var level_path := level_serializer.get_level_path(level_file)
	var level_data := level_serializer.load_level_from_file(level_path)

	if level_data:
		level_name_input.text = level_data.level_name
		if current_mode == Mode.SAVE:
			author_input.text = level_data.author
			description_input.text = level_data.description


## Save button pressed
func _on_save_pressed() -> void:
	var level_name := level_name_input.text.strip_edges()

	if level_name.is_empty():
		print("[SaveLoadDialog] Level name is required")
		return

	if !level_serializer:
		push_error("[SaveLoadDialog] No level serializer")
		return

	# Create metadata
	var metadata := {
		"author": author_input.text.strip_edges(),
		"description": description_input.text.strip_edges()
	}

	# Serialize level
	var level_data := level_serializer.serialize_level(level_name, metadata)

	# Save to file
	var success := level_serializer.save_level_to_file(level_data)

	if success:
		print("[SaveLoadDialog] Level saved successfully: %s" % level_name)
		level_saved.emit(level_name)
		visible = false
	else:
		print("[SaveLoadDialog] Failed to save level")


## Load button pressed
func _on_load_pressed() -> void:
	var selected_items := levels_list.get_selected_items()

	if selected_items.is_empty():
		print("[SaveLoadDialog] No level selected")
		return

	var level_file: String = levels_list.get_item_metadata(selected_items[0])
	var level_path := level_serializer.get_level_path(level_file)

	if !level_serializer:
		push_error("[SaveLoadDialog] No level serializer")
		return

	# Load level data
	var level_data := level_serializer.load_level_from_file(level_path)

	if !level_data:
		print("[SaveLoadDialog] Failed to load level")
		return

	# Build level from data
	var success := level_serializer.build_level_from_data(level_data)

	if success:
		print("[SaveLoadDialog] Level loaded successfully: %s" % level_data.level_name)
		level_loaded.emit(level_file)
		visible = false
	else:
		print("[SaveLoadDialog] Failed to build level")


## Delete button pressed
func _on_delete_pressed() -> void:
	var selected_items := levels_list.get_selected_items()

	if selected_items.is_empty():
		print("[SaveLoadDialog] No level selected")
		return

	var level_file: String = levels_list.get_item_metadata(selected_items[0])

	# Confirm deletion (simple version - can be improved with confirmation dialog)
	print("[SaveLoadDialog] Deleting level: %s" % level_file)

	if level_serializer:
		var success := level_serializer.delete_level(level_file)
		if success:
			# Refresh list
			populate_levels_list()


## Cancel button pressed
func _on_cancel_pressed() -> void:
	visible = false
