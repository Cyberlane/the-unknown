@tool
extends Area3D

## DimensionGate - Area that controls dimension swapping
##
## Two modes:
## - PASSIVE: Prevents player from swapping dimensions while inside (static zone)
## - ACTIVE: Forces player to a specific dimension when they enter (portal)

enum GateMode { PASSIVE, ACTIVE }

@export_group("Gate Settings")
@export var mode: GateMode = GateMode.PASSIVE
    set(value):
        mode = value
        _update_visual()

@export var target_dimension: DimensionManager.Dimension = DimensionManager.Dimension.NORMAL
    set(value):
        target_dimension = value
        _update_visual()

@export_group("Visual Settings")
@export var gate_size: Vector3 = Vector3(4, 4, 0.5)
    set(value):
        gate_size = value
        _update_visual()

@export var passive_color: Color = Color(0.5, 0.5, 0.5, 0.3)
@export var active_color: Color = Color(0.2, 0.6, 1.0, 0.4)

@export_group("Active Mode Settings")
@export var force_once: bool = false  ## Only force dimension change once per entry
@export var show_transition_effect: bool = true

# Dimension tags
@export_group("Dimension Tags")
@export var dimension_tags: Array[String] = []

# Internal state
var player_inside: bool = false
var has_forced_this_entry: bool = false
var placeholder_mesh: MeshInstance3D
var collision_shape: CollisionShape3D

func _ready():
    if Engine.is_editor_hint():
        _setup_editor_visual()
    else:
        _setup_runtime()

func _setup_editor_visual():
    # Create or update visual placeholder for editor
    _ensure_placeholder_exists()
    _update_visual()

func _setup_runtime():
    # Runtime setup
    collision_layer = 0
    collision_mask = 1  # Detect player on layer 1

    # Hide placeholder in game
    if placeholder_mesh:
        placeholder_mesh.visible = false

    # Connect signals
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

    print("DimensionGate '%s' ready - Mode: %s" % [name, "PASSIVE" if mode == GateMode.PASSIVE else "ACTIVE"])

func _ensure_placeholder_exists():
    # Find or create placeholder mesh
    placeholder_mesh = get_node_or_null("PlaceholderMesh")
    if not placeholder_mesh:
        placeholder_mesh = MeshInstance3D.new()
        placeholder_mesh.name = "PlaceholderMesh"
        add_child(placeholder_mesh)
        if Engine.is_editor_hint():
            placeholder_mesh.owner = get_tree().edited_scene_root

    # Find or create collision shape
    collision_shape = get_node_or_null("CollisionShape3D")
    if not collision_shape:
        collision_shape = CollisionShape3D.new()
        collision_shape.name = "CollisionShape3D"
        add_child(collision_shape)
        if Engine.is_editor_hint():
            collision_shape.owner = get_tree().edited_scene_root

func _update_visual():
    if not Engine.is_editor_hint():
        return

    _ensure_placeholder_exists()

    # Create box mesh
    var box_mesh = BoxMesh.new()
    box_mesh.size = gate_size

    # Create material based on mode
    var material = StandardMaterial3D.new()
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.disable_receive_shadows = true
    material.albedo_color = passive_color if mode == GateMode.PASSIVE else active_color

    # Add dimension-specific tint for active mode
    if mode == GateMode.ACTIVE:
        match target_dimension:
            DimensionManager.Dimension.NORMAL:
                material.albedo_color = Color(0.7, 0.7, 0.7, 0.4)
            DimensionManager.Dimension.VIKING:
                material.albedo_color = Color(0.3, 0.5, 1.0, 0.4)
            DimensionManager.Dimension.AZTEC:
                material.albedo_color = Color(1.0, 0.8, 0.3, 0.4)
            DimensionManager.Dimension.NIGHTMARE:
                material.albedo_color = Color(0.8, 0.2, 0.2, 0.4)

    placeholder_mesh.mesh = box_mesh
    placeholder_mesh.set_surface_override_material(0, material)

    # Update collision shape
    var box_shape = BoxShape3D.new()
    box_shape.size = gate_size
    collision_shape.shape = box_shape

    # Add label in editor
    _update_label()

func _update_label():
    if not Engine.is_editor_hint():
        return

    var label = get_node_or_null("Label3D")
    if not label:
        label = Label3D.new()
        label.name = "Label3D"
        label.position = Vector3(0, gate_size.y / 2 + 0.5, 0)
        label.font_size = 24
        label.outline_size = 4
        label.outline_modulate = Color.BLACK
        add_child(label)
        if Engine.is_editor_hint():
            label.owner = get_tree().edited_scene_root

    # Update label text based on mode
    var dim_name = ""
    if mode == GateMode.PASSIVE:
        label.text = "DIMENSION LOCK ZONE"
        label.modulate = passive_color
    else:
        match target_dimension:
            DimensionManager.Dimension.NORMAL:
                dim_name = "NORMAL"
            DimensionManager.Dimension.VIKING:
                dim_name = "VIKING"
            DimensionManager.Dimension.AZTEC:
                dim_name = "AZTEC"
            DimensionManager.Dimension.NIGHTMARE:
                dim_name = "NIGHTMARE"
        label.text = "PORTAL → %s" % dim_name
        label.modulate = active_color

func _on_body_entered(body: Node3D):
    if not body.is_in_group("player"):
        return

    player_inside = true
    has_forced_this_entry = false

    if mode == GateMode.PASSIVE:
        _activate_passive_mode()
    elif mode == GateMode.ACTIVE:
        _activate_portal()

func _on_body_exited(body: Node3D):
    if not body.is_in_group("player"):
        return

    player_inside = false
    has_forced_this_entry = false

    if mode == GateMode.PASSIVE:
        _deactivate_passive_mode()

func _activate_passive_mode():
    # Lock dimension swapping
    DimensionManager.dimension_locked = true
    print("DimensionGate: Dimension swapping LOCKED")

func _deactivate_passive_mode():
    # Unlock dimension swapping
    DimensionManager.dimension_locked = false
    print("DimensionGate: Dimension swapping UNLOCKED")

func _activate_portal():
    # Check if we should force (based on force_once setting)
    if force_once and has_forced_this_entry:
        return

    # Force dimension change
    var current_dim = DimensionManager.current_dimension
    if current_dim != target_dimension:
        DimensionManager.switch_to(target_dimension)
        has_forced_this_entry = true
        print("DimensionGate: Forced dimension change to %s" % target_dimension)
    else:
        print("DimensionGate: Player already in target dimension %s" % target_dimension)

## Public API: Check if player is currently inside this gate
func is_player_inside() -> bool:
    return player_inside

## Public API: Manually trigger the gate effect (useful for scripted sequences)
func trigger():
    if mode == GateMode.PASSIVE:
        _activate_passive_mode()
    else:
        _activate_portal()

## Public API: Switch between modes at runtime
func set_mode(new_mode: GateMode):
    mode = new_mode
    _update_visual()

## Public API: Change target dimension at runtime
func set_target_dimension(new_dimension: DimensionManager.Dimension):
    target_dimension = new_dimension
    _update_visual()
