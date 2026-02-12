extends PanelContainer
class_name DimensionTagEditor
## UI for editing dimension tags on blocks and objects

signal tags_updated(new_tags: Array[String])

# References
var target_node: Node = null  # PlaceableBlock or PlaceableObject being edited

# UI nodes (will be created programmatically)
var title_label: Label
var normal_checkbox: CheckBox
var aztec_checkbox: CheckBox
var viking_checkbox: CheckBox
var nightmare_checkbox: CheckBox
var apply_button: Button
var cancel_button: Button


func _ready() -> void:
	visible = false
	create_ui()


## Create the UI programmatically
func create_ui() -> void:
	# Set up panel
	custom_minimum_size = Vector2(300, 250)

	# Main container
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	# Title
	title_label = Label.new()
	title_label.text = "Dimension Tags"
	title_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(title_label)

	# Separator
	var separator1 := HSeparator.new()
	vbox.add_child(separator1)

	# Description
	var desc_label := Label.new()
	desc_label.text = "Select which dimensions this object appears in:"
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_label)

	# Checkboxes
	normal_checkbox = CheckBox.new()
	normal_checkbox.text = "Normal"
	normal_checkbox.button_pressed = true
	vbox.add_child(normal_checkbox)

	aztec_checkbox = CheckBox.new()
	aztec_checkbox.text = "Aztec"
	aztec_checkbox.button_pressed = true
	vbox.add_child(aztec_checkbox)

	viking_checkbox = CheckBox.new()
	viking_checkbox.text = "Viking"
	viking_checkbox.button_pressed = true
	vbox.add_child(viking_checkbox)

	nightmare_checkbox = CheckBox.new()
	nightmare_checkbox.text = "Nightmare"
	nightmare_checkbox.button_pressed = true
	vbox.add_child(nightmare_checkbox)

	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer)

	# Button container
	var button_hbox := HBoxContainer.new()
	button_hbox.add_theme_constant_override("separation", 10)
	vbox.add_child(button_hbox)

	# Cancel button
	cancel_button = Button.new()
	cancel_button.text = "Cancel"
	cancel_button.pressed.connect(_on_cancel_pressed)
	button_hbox.add_child(cancel_button)

	# Spacer
	var button_spacer := Control.new()
	button_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_hbox.add_child(button_spacer)

	# Apply button
	apply_button = Button.new()
	apply_button.text = "Apply"
	apply_button.pressed.connect(_on_apply_pressed)
	button_hbox.add_child(apply_button)


## Open the editor for a specific target
func open_for_target(target: Node) -> void:
	target_node = target

	if !target:
		return

	# Get current tags
	var tags: Array[String] = []

	if target is PlaceableBlock:
		tags = target.dimension_tags.duplicate()
		title_label.text = "Block Dimension Tags"
	elif target is PlaceableObject:
		tags = target.dimension_tags.duplicate()
		title_label.text = "Object Dimension Tags"
	else:
		push_error("[DimensionTagEditor] Invalid target type")
		return

	# Update checkboxes
	normal_checkbox.button_pressed = "Normal" in tags
	aztec_checkbox.button_pressed = "Aztec" in tags
	viking_checkbox.button_pressed = "Viking" in tags
	nightmare_checkbox.button_pressed = "Nightmare" in tags

	# Show the panel
	visible = true
	position = get_viewport().get_mouse_position()

	# Ensure it's within screen bounds
	var viewport_rect := get_viewport().get_visible_rect()
	if position.x + size.x > viewport_rect.size.x:
		position.x = viewport_rect.size.x - size.x - 10
	if position.y + size.y > viewport_rect.size.y:
		position.y = viewport_rect.size.y - size.y - 10


## Apply the changes
func _on_apply_pressed() -> void:
	if !target_node:
		return

	# Build new tags array
	var new_tags: Array[String] = []

	if normal_checkbox.button_pressed:
		new_tags.append("Normal")
	if aztec_checkbox.button_pressed:
		new_tags.append("Aztec")
	if viking_checkbox.button_pressed:
		new_tags.append("Viking")
	if nightmare_checkbox.button_pressed:
		new_tags.append("Nightmare")

	# Apply to target
	if target_node is PlaceableBlock:
		target_node.set_dimension_tags(new_tags)
		print("[DimensionTagEditor] Updated block tags: %s" % str(new_tags))
	elif target_node is PlaceableObject:
		target_node.set_dimension_tags(new_tags)
		print("[DimensionTagEditor] Updated object tags: %s" % str(new_tags))

	# Emit signal
	tags_updated.emit(new_tags)

	# Close the editor
	visible = false
	target_node = null


## Cancel editing
func _on_cancel_pressed() -> void:
	visible = false
	target_node = null
