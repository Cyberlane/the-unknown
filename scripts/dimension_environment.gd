# scripts/dimension_environment.gd
class_name DimensionEnvironment
extends Node

@export_group("Dimension Environments")
@export var normal_environment: Environment
@export var viking_environment: Environment
@export var aztec_environment: Environment
@export var nightmare_environment: Environment

@export_group("Transition Settings")
@export var transition_duration: float = 0.5
@export var smooth_sky_transition: bool = true
@export var smooth_fog_transition: bool = true
@export var smooth_exposure_transition: bool = true

@onready var world_environment: WorldEnvironment = _find_or_create_world_environment()

var tween: Tween
var current_dimension: int = -1

func _ready():
	# Connect to the global manager
	DimensionManager.dimension_changed.connect(_on_dimension_changed)
	# Set initial state (instant, no transition on startup)
	current_dimension = DimensionManager.current_dimension
	_apply_environment_instant(DimensionManager.current_dimension)

func _on_dimension_changed(new_dim):
	if new_dim == current_dimension:
		return

	_transition_to_environment(new_dim)
	current_dimension = new_dim

func _transition_to_environment(target_dim: int):
	if not world_environment or not world_environment.environment:
		return

	var target_env = _get_environment_for_dimension(target_dim)
	if not target_env:
		return

	# Kill any existing tween
	if tween:
		tween.kill()

	# Create new tween
	tween = create_tween()
	tween.set_parallel(true)  # All properties transition simultaneously
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	var current_env = world_environment.environment

	# Transition sky colors (if both environments have sky)
	if smooth_sky_transition and current_env.sky and target_env.sky:
		var current_sky_mat = current_env.sky.sky_material
		var target_sky_mat = target_env.sky.sky_material

		if current_sky_mat is ProceduralSkyMaterial and target_sky_mat is ProceduralSkyMaterial:
			# Sky top color
			tween.tween_property(current_sky_mat, "sky_top_color",
				target_sky_mat.sky_top_color, transition_duration)

			# Sky horizon color
			tween.tween_property(current_sky_mat, "sky_horizon_color",
				target_sky_mat.sky_horizon_color, transition_duration)

			# Ground horizon color
			tween.tween_property(current_sky_mat, "ground_horizon_color",
				target_sky_mat.ground_horizon_color, transition_duration)

			# Ground bottom color
			if target_sky_mat.ground_bottom_color != Color.BLACK:
				tween.tween_property(current_sky_mat, "ground_bottom_color",
					target_sky_mat.ground_bottom_color, transition_duration)

	# Transition ambient light
	tween.tween_property(current_env, "ambient_light_color",
		target_env.ambient_light_color, transition_duration)
	tween.tween_property(current_env, "ambient_light_energy",
		target_env.ambient_light_energy, transition_duration)

	# Transition fog (if enabled in either environment)
	if smooth_fog_transition:
		# Check if fog is enabled in target
		if target_env.fog_enabled:
			# Enable fog if not already enabled
			if not current_env.fog_enabled:
				current_env.fog_enabled = true
				# Start from zero density
				current_env.fog_density = 0.0

			# Transition fog properties
			tween.tween_property(current_env, "fog_density",
				target_env.fog_density, transition_duration)
			tween.tween_property(current_env, "fog_light_color",
				target_env.fog_light_color, transition_duration)
			tween.tween_property(current_env, "fog_light_energy",
				target_env.fog_light_energy, transition_duration)
		else:
			# Fade out fog if target has it disabled
			if current_env.fog_enabled:
				tween.tween_property(current_env, "fog_density",
					0.0, transition_duration)
				# Disable after transition
				tween.finished.connect(func(): current_env.fog_enabled = false)

	# Transition exposure/tonemap
	if smooth_exposure_transition:
		tween.tween_property(current_env, "tonemap_exposure",
			target_env.tonemap_exposure, transition_duration)

func _apply_environment_instant(dim: int):
	if not world_environment:
		return

	var env = _get_environment_for_dimension(dim)
	if env:
		world_environment.environment = env

func _get_environment_for_dimension(dim: int) -> Environment:
	match dim:
		DimensionManager.Dimension.NORMAL:
			return normal_environment
		DimensionManager.Dimension.VIKING:
			return viking_environment
		DimensionManager.Dimension.AZTEC:
			return aztec_environment
		DimensionManager.Dimension.NIGHTMARE:
			return nightmare_environment
	return null

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
