# scripts/dimension_trigger.gd
@tool
class_name DimensionTrigger
extends Area3D

enum TriggerDimension {
    NORMAL,
    VIKING,
    AZTEC,
    NIGHTMARE,
    ANY  # Triggers in all dimensions
}

@export_group("Trigger Settings")
@export var active_dimension: TriggerDimension = TriggerDimension.NORMAL
@export var one_shot: bool = false
@export_multiline var debug_message: String = ""

@export_group("Editor Preview")
@export var show_debug_mesh: bool = true:
    set(value):
        show_debug_mesh = value
        _update_debug_mesh()

signal dimension_triggered(body: Node3D)

var has_triggered: bool = false
var debug_mesh_instance: MeshInstance3D

func _ready():
    # Set up collision
    collision_layer = 0
    collision_mask = 1  # Player layer

    if Engine.is_editor_hint():
        _setup_debug_mesh()
    else:
        # Runtime: connect to body_entered
        body_entered.connect(_on_body_entered)

        # Remove debug mesh at runtime
        if debug_mesh_instance:
            debug_mesh_instance.queue_free()

func _on_body_entered(body: Node3D):
    # Check if one-shot has already triggered
    if one_shot and has_triggered:
        return

    # Check if we're in the correct dimension
    if not _is_dimension_active():
        return

    # Trigger is active!
    has_triggered = true
    dimension_triggered.emit(body)

    if debug_message and not debug_message.is_empty():
        print("DimensionTrigger '", name, "': ", debug_message)

func _is_dimension_active() -> bool:
    # ANY dimension always triggers
    if active_dimension == TriggerDimension.ANY:
        return true

    # Check if current dimension matches
    if DimensionManager:
        return int(DimensionManager.current_dimension) == active_dimension

    return false

func _setup_debug_mesh():
    if not show_debug_mesh:
        return

    # Create a semi-transparent debug mesh to show trigger area
    debug_mesh_instance = MeshInstance3D.new()
    debug_mesh_instance.name = "DebugMesh"
    add_child(debug_mesh_instance)

    # Set owner for scene saving
    if get_tree() and get_tree().edited_scene_root:
        debug_mesh_instance.owner = get_tree().edited_scene_root

    _update_debug_mesh()

func _update_debug_mesh():
    if not Engine.is_editor_hint() or not debug_mesh_instance:
        return

    if not show_debug_mesh:
        if debug_mesh_instance:
            debug_mesh_instance.visible = false
        return

    # Create a box mesh based on collision shape
    var collision_shape = _find_collision_shape()
    if collision_shape and collision_shape.shape:
        var shape = collision_shape.shape

        if shape is BoxShape3D:
            var box_mesh = BoxMesh.new()
            box_mesh.size = shape.size
            debug_mesh_instance.mesh = box_mesh
        elif shape is SphereShape3D:
            var sphere_mesh = SphereMesh.new()
            sphere_mesh.radius = shape.radius
            sphere_mesh.height = shape.radius * 2
            debug_mesh_instance.mesh = sphere_mesh
        elif shape is CapsuleShape3D:
            var capsule_mesh = CapsuleMesh.new()
            capsule_mesh.radius = shape.radius
            capsule_mesh.height = shape.height
            debug_mesh_instance.mesh = capsule_mesh

    # Set material based on dimension
    var material = StandardMaterial3D.new()
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    material.albedo_color = _get_dimension_color()
    debug_mesh_instance.material_override = material
    debug_mesh_instance.visible = true

func _find_collision_shape() -> CollisionShape3D:
    for child in get_children():
        if child is CollisionShape3D:
            return child
    return null

func _get_dimension_color() -> Color:
    match active_dimension:
        TriggerDimension.NORMAL:
            return Color(0.8, 0.8, 0.8, 0.3)
        TriggerDimension.VIKING:
            return Color(0.2, 0.5, 0.9, 0.3)
        TriggerDimension.AZTEC:
            return Color(0.9, 0.7, 0.2, 0.3)
        TriggerDimension.NIGHTMARE:
            return Color(0.6, 0.1, 0.1, 0.3)
        TriggerDimension.ANY:
            return Color(0.5, 0.5, 0.5, 0.3)
    return Color.WHITE
