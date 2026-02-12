extends CharacterBody3D

# Export variables for designer-facing parameters
export(Resource) var enemy_config: EnemyResource

# State machine states
enum States { IDLE, PATROL, CHASE, GRAPPLE, STUNNED, DEAD }

@onready var event_bus = get_node("/root/EventBus")
@onready var navigation_agent = $NavigationAgent3D

var current_state: States = States.IDLE
var target_position: Vector3 = Vector3.ZERO
var grapple_timer: Timer

func _ready():
    grapple_timer = Timer.new()
    add_child(grapple_timer)
    grapple_timer.timeout.connect(_on_grapple_timeout)
    grapple_timer.wait_time = 1.0  # Time to drain health while grappling

    # Initialize with enemy config
    health = enemy_config.base_health

func _process(delta):
    match current_state:
        States.IDLE:
            idle()
        States.PATROL:
            patrol(delta)
        States.CHASE:
            chase(delta)
        States.GRAPPLE:
            grapple(delta)
        States.STUNNED:
            stunned(delta)
        States.DEAD:
            dead()

func idle():
    # Implement idle behavior
    pass

func patrol(delta):
    # Implement patrol behavior
    if navigation_agent.is_navigation_finished():
        target_position = get_random_point_in_navmesh()
        navigation_agent.set_target_location(target_position)

func chase(delta):
    # Implement chase behavior
    var direction = (global_transform.origin - global_position).normalized()
    velocity = direction * enemy_config.speed
    move_and_slide()

func grapple(delta):
    # Implement grapple behavior
    grapple_timer.start()
    event_bus.emit_signal("player_grappled", self)

func stunned(delta):
    # Implement stunned behavior
    pass

func dead():
    # Implement dead behavior
    queue_free()

func _on_grapple_timeout():
    # Drain health while grappling
    var player = get_node("/root/Player")
    if player:
        player.take_damage(enemy_config.damage_amount, enemy_config.damage_type)

func take_damage(amount: int, damage_type: String):
    match damage_type:
        "health":
            health -= amount
            if health <= 0:
                current_state = States.DEAD
        "sanity":
            # Implement sanity damage handling if needed
            pass

func get_random_point_in_navmesh() -> Vector3:
    var nav_mesh = NavigationServer2D.get_singleton().get_map(get_world_2d().navigation_map_id).get_agents()[0].nav_mesh
    return nav_mesh.random_point()
