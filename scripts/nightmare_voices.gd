# scripts/nightmare_voices.gd
extends Node

@export var voice_lines: Array[String] = [
    "They're watching you...",
    "You don't belong here.",
    "Turn back while you still can.",
    "The shadows whisper your name...",
    "This dimension hungers...",
    "You feel eyes upon you from every corner.",
    "Something stirs in the darkness.",
    "Your presence disturbs the void.",
    "Time moves differently here...",
    "Do you hear them too?"
]

@export var auto_dismiss_time: float = 4.0
@export var show_on_every_entry: bool = true

var last_dimension: DimensionManager.Dimension
var nightmare_entry_count: int = 0
var dismiss_timer: Timer

func _ready():
    # Connect to dimension changes
    DimensionManager.dimension_changed.connect(_on_dimension_changed)
    last_dimension = DimensionManager.current_dimension

    # Create timer for auto-dismissing dialogue
    dismiss_timer = Timer.new()
    dismiss_timer.one_shot = true
    dismiss_timer.timeout.connect(_auto_dismiss_dialogue)
    add_child(dismiss_timer)

func _on_dimension_changed(new_dim: DimensionManager.Dimension):
    # Check if we just entered the Nightmare dimension
    if new_dim == DimensionManager.Dimension.NIGHTMARE and last_dimension != DimensionManager.Dimension.NIGHTMARE:
        nightmare_entry_count += 1

        # Show voice line every time or only first time
        if show_on_every_entry or nightmare_entry_count == 1:
            _show_random_voice_line()

    last_dimension = new_dim

func _show_random_voice_line():
    if voice_lines.is_empty():
        return

    # Pick a random voice line
    var random_index = randi() % voice_lines.size()
    var line = voice_lines[random_index]

    # Show it in the dialogue UI
    var dialogue_ui = get_tree().get_first_node_in_group("dialogue_ui")
    if dialogue_ui and dialogue_ui.has_method("show_dialogue"):
        dialogue_ui.show_dialogue(line)

        # Start auto-dismiss timer
        if auto_dismiss_time > 0:
            dismiss_timer.start(auto_dismiss_time)

func _auto_dismiss_dialogue():
    var dialogue_ui = get_tree().get_first_node_in_group("dialogue_ui")
    if dialogue_ui and dialogue_ui.has_method("hide_dialogue"):
        dialogue_ui.hide_dialogue()
