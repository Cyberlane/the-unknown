# scripts/dimension_object.gd
class_name DimensionObject
extends Node3D

@export_group("Dimension Meshes")
@export var normal_mesh: Node3D
@export var viking_mesh: Node3D
@export var aztec_mesh: Node3D
@export var nightmare_mesh: Node3D

func _ready():
    # Connect to the global manager
    DimensionManager.dimension_changed.connect(_on_dimension_changed)
    # Set initial state
    _update_visibility(DimensionManager.current_dimension)

func _on_dimension_changed(new_dim):
    _update_visibility(new_dim)

func _update_visibility(active_dim):
    if normal_mesh: normal_mesh.visible = (active_dim == DimensionManager.Dimension.NORMAL)
    if viking_mesh: viking_mesh.visible = (active_dim == DimensionManager.Dimension.VIKING)
    if aztec_mesh: aztec_mesh.visible = (active_dim == DimensionManager.Dimension.AZTEC)
    if nightmare_mesh: nightmare_mesh.visible = (active_dim == DimensionManager.Dimension.NIGHTMARE)
