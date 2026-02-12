extends CharacterBody3D

# Export variables for designer-facing parameters
export(float) var max_health: float = 100.0
export(float) var health: float = 100.0

# EventBus reference
onready var event_bus = get_node("/root/EventBus")

# Movement configuration
var movement_config: Resource = preload("res://assets/configs/movement_config.tres")

func _ready():
    # Subscribe to health change events
    event_bus.connect("health_changed", self, "_on_health_changed")

func _process(delta):
    var speed_multiplier = 1.0
    
    if health < 50:
        speed_multiplier *= (health / 50)
    
    velocity = Vector3.ZERO
    if Input.is_action_pressed("ui_right"):
        velocity.x += 1
    if Input.is_action_pressed("ui_left"):
        velocity.x -= 1
    if Input.is_action_pressed("ui_up"):
        velocity.z -= 1
    if Input.is_action_pressed("ui_down"):
        velocity.z += 1
    
    if Input.is_action_pressed("sprint"):
        speed_multiplier *= movement_config.sprint_multiplier
    elif Input.is_action_pressed("crouch"):
        speed_multiplier *= movement_config.crouch_multiplier
    
    velocity = velocity.normalized() * movement_config.movement_speed * speed_multiplier
    move_and_slide()

func _on_health_changed(new_health: float):
    health = new_health
    if health < 20:
        event_bus.emit_signal("desaturate_screen", true)
        event_bus.emit_signal("play_laboured_breathing")
    else:
        event_bus.emit_signal("desaturate_screen", false)

func _on_exit_tree():
    # Unsubscribe from health change events
    event_bus.disconnect("health_changed", self, "_on_health_changed")
