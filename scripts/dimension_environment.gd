# scripts/dimension_environment.gd
class_name DimensionEnvironment
extends Node

@export_group("Dimension Environments")
@export var normal_environment: Environment
@export var viking_environment: Environment
@export var aztec_environment: Environment
@export var nightmare_environment: Environment

@onready var world_environment: WorldEnvironment = _find_or_create_world_environment()

func _ready():
	# Connect to the global manager
	DimensionManager.dimension_changed.connect(_on_dimension_changed)
	# Set initial state
	_update_active_environment(DimensionManager.current_dimension)

func _on_dimension_changed(new_dim):
	_update_active_environment(new_dim)

func _update_active_environment(active_dim):
	if not world_environment:
		return

	# Switch the environment resource based on active dimension
	match active_dim:
		DimensionManager.Dimension.NORMAL:
			world_environment.environment = normal_environment
		DimensionManager.Dimension.VIKING:
			world_environment.environment = viking_environment
		DimensionManager.Dimension.AZTEC:
			world_environment.environment = aztec_environment
		DimensionManager.Dimension.NIGHTMARE:
			world_environment.environment = nightmare_environment

func _find_or_create_world_environment() -> WorldEnvironment:
	# Look for existing WorldEnvironment in parent
	if get_parent():
		for child in get_parent().get_children():
			if child is WorldEnvironment:
				return child

	# Create one if none exists
	var new_env = WorldEnvironment.new()
	get_parent().add_child(new_env)
	return new_env
