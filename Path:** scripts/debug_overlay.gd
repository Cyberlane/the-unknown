extends CanvasLayer

@export var fps_label: Label = null
@export var position_label: Label = null
@export var state_label: Label = null

var event_bus: EventBus = preload("res://autoload/EventBus.gd")

func _ready():
    # Initialize labels and add them to the canvas
    fps_label = Label.new()
    fps_label.text = "FPS: 0"
    fps_label.rect_position = Vector2(10, 10)
    add_child(fps_label)

    position_label = Label.new()
    position_label.text = "Position: (0, 0, 0)"
    position_label.rect_position = Vector2(10, 30)
    add_child(position_label)

    state_label = Label.new()
    state_label.text = "State: None"
    state_label.rect_position = Vector2(10, 50)
    add_child(state_label)

func _process(delta):
    # Update FPS label
    fps_label.text = "FPS: {get_process_frames_per_second()}"

    # Update position label
    var player = get_node("/root/Player")
    if player:
        position_label.text = f"Position: ({player.global_transform.origin.x}, {player.global_transform.origin.y}, {player.global_transform.origin.z})"

    # Update state label (assuming a state machine)
    var current_state = get_current_state()
    state_label.text = f"State: {current_state}"

func get_process_frames_per_second() -> int:
    return round(get_process_delta_time() * 1000)

func get_current_state() -> String:
    # Implement this function to return the current state of your game
    return "None"
