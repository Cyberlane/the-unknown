extends CanvasLayer
class_name DebugOverlay
## Debug HUD showing FPS, player position, state, and other debug info

@onready var debug_label: Label = $MarginContainer/VBoxContainer/DebugLabel
@onready var fps_label: Label = $MarginContainer/VBoxContainer/FPSLabel

var player: FirstPersonController = null
var is_visible: bool = true

func _ready() -> void:
	# Find player in scene
	await get_tree().process_frame  # Wait for scene to be fully loaded
	find_player()

	# Listen for debug toggle
	EventBus.debug_overlay_toggled.connect(_on_debug_toggle)

	# Set initial visibility
	visible = is_visible

	# Create UI if it doesn't exist in scene
	if not debug_label:
		create_debug_ui()

func _process(_delta: float) -> void:
	if not is_visible:
		return

	update_debug_info()

func find_player() -> void:
	"""Find the FirstPersonController in the scene"""
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0] as FirstPersonController
		if player:
			print("DebugOverlay: Found player")
	else:
		# Try finding by class name
		for node in get_tree().root.find_children("*", "FirstPersonController"):
			player = node as FirstPersonController
			break

func update_debug_info() -> void:
	"""Update all debug labels"""
	if fps_label:
		fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

	if debug_label and player:
		var debug_info = player.get_debug_info()
		var text = ""
		text += "Position: (%.1f, %.1f, %.1f)\n" % [debug_info.position.x, debug_info.position.y, debug_info.position.z]
		text += "Velocity: (%.1f, %.1f, %.1f)\n" % [debug_info.velocity.x, debug_info.velocity.y, debug_info.velocity.z]
		text += "Speed: %.1f m/s\n" % debug_info.speed
		text += "On Floor: %s\n" % str(debug_info.is_on_floor)
		text += "Crouching: %s\n" % str(debug_info.is_crouching)
		text += "Sprinting: %s\n" % str(debug_info.is_sprinting)

		debug_label.text = text

func _on_debug_toggle(new_visible: bool) -> void:
	"""Toggle debug overlay visibility"""
	is_visible = new_visible
	visible = is_visible

func _input(event: InputEvent) -> void:
	"""Handle input for toggling debug overlay"""
	if event.is_action_pressed("toggle_debug"):
		is_visible = !is_visible
		EventBus.debug_overlay_toggled.emit(is_visible)

func create_debug_ui() -> void:
	"""Create debug UI elements programmatically if not in scene"""
	# Create margin container
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_TOP_LEFT)
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	add_child(margin)

	# Create VBox
	var vbox = VBoxContainer.new()
	margin.add_child(vbox)

	# Create FPS label
	fps_label = Label.new()
	fps_label.name = "FPSLabel"
	fps_label.add_theme_color_override("font_color", Color(0, 1, 0))  # Green
	vbox.add_child(fps_label)

	# Create debug info label
	debug_label = Label.new()
	debug_label.name = "DebugLabel"
	debug_label.add_theme_color_override("font_color", Color(1, 1, 1))  # White
	vbox.add_child(debug_label)

	print("DebugOverlay: Created UI programmatically")
