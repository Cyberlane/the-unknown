extends CharacterBody3D

# Export variables for designer-facing parameters
export var move_speed: float = 5.0
export var jump_force: float = 10.0

# Event bus for communication
var event_bus: EventBus

func _ready():
    # Initialize the event bus
    event_bus = get_node("/root/EventBus")

func _process(delta):
    handle_input()

func handle_input():
    var velocity = Vector3.ZERO
    
    if Input.is_action_pressed("ui_right"):
        velocity.x += 1.0
    if Input.is_action_pressed("ui_left"):
        velocity.x -= 1.0
    if Input.is_action_pressed("ui_down"):
        velocity.z += 1.0
    if Input.is_action_pressed("ui_up"):
        velocity.z -= 1.0
    
    velocity = velocity.normalized() * move_speed
    velocity.y = velocity.y + jump_force * Input.is_action_just_pressed("ui_jump")
    
    move_and_slide(velocity)

func _input(event):
    if event is InputEventKey and event.pressed:
        match event.scancode:
            KEY_SPACE: emit_signal("jump")
