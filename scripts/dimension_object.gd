# scripts/dimension_object.gd
@tool
class_name DimensionObject
extends Node3D

enum PreviewDimension {
    NORMAL,
    VIKING,
    AZTEC,
    NIGHTMARE
}

@export_group("Editor Preview")
@export var preview_dimension: PreviewDimension = PreviewDimension.NORMAL:
    set(value):
        preview_dimension = value
        # Update visibility immediately when changed in editor
        _update_visibility(preview_dimension)

@export_group("Dimension Meshes")
@export var normal_mesh: Node3D
@export var viking_mesh: Node3D
@export var aztec_mesh: Node3D
@export var nightmare_mesh: Node3D

@export_group("Dimension Collisions")
@export var normal_collision: CollisionShape3D
@export var viking_collision: CollisionShape3D
@export var aztec_collision: CollisionShape3D
@export var nightmare_collision: CollisionShape3D

@export_group("Material Configuration")
@export(Resource) var material_config: Resource = preload("res://assets/configs/material_config.tres")

func _ready():
    # Only connect to DimensionManager at runtime (not in editor)
    if Engine.is_editor_hint():
        # In editor: show preview dimension
        _update_visibility(preview_dimension)
    else:
        # In game: connect to the global manager and use runtime dimension
        if DimensionManager:
            DimensionManager.dimension_changed.connect(_on_dimension_changed)
            _update_visibility(DimensionManager.current_dimension)

func _on_dimension_changed(new_dim):
    _update_visibility(new_dim)

func _update_visibility(active_dim: int):
    # Update mesh visibility
    normal_mesh.visible = (active_dim == PreviewDimension.NORMAL) if normal_mesh else false
    viking_mesh.visible = (active_dim == PreviewDimension.VIKING) if viking_mesh else false
    aztec_mesh.visible = (active_dim == PreviewDimension.AZTEC) if aztec_mesh else false
    nightmare_mesh.visible = (active_dim == PreviewDimension.NIGHTMARE) if nightmare_mesh else false

    # Update collision shape enabled state (only at runtime, not in editor)
    if not Engine.is_editor_hint():
        normal_collision.disabled = (active_dim != PreviewDimension.NORMAL) if normal_collision else true
        viking_collision.disabled = (active_dim != PreviewDimension.VIKING) if viking_collision else true
        aztec_collision.disabled = (active_dim != PreviewDimension.AZTEC) if aztec_collision else true
        nightmare_collision.disabled = (active_dim != PreviewDimension.NIGHTMARE) if nightmare_collision else true

    # Update material based on active dimension
    _update_material(active_dim)

func _update_material(active_dim: int):
    for mat_config in material_config.materials:
        if mat_config.dimension == active_dim:
            for mesh in [$normal_mesh, $viking_mesh, $aztec_mesh, $nightmare_mesh]:
                if mesh and mesh.get_surface_count() > 0:
                    mesh.surface_set_material(0, mat_config.material)
            break
