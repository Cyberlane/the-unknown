# scripts/atmosphere_manager.gd
class_name AtmosphereManager
extends Node

@export_group("Dimension Environments")
@export var normal_environment: Environment
@export var viking_environment: Environment
@export var aztec_environment: Environment
@export var nightmare_environment: Environment

@export_group("Dimension Light Settings")
@export var normal_light_color: Color = Color(1.0, 0.95, 0.9, 1.0)
@export var normal_light_energy: float = 1.0

@export var viking_light_color: Color = Color(0.7, 0.8, 1.0, 1.0)
@export var viking_light_energy: float = 0.85

@export var aztec_light_color: Color = Color(1.0, 0.9, 0.7, 1.0)
@export var aztec_light_energy: float = 1.2

@export var nightmare_light_color: Color = Color(0.8, 0.4, 0.4, 1.0)
@export var nightmare_light_energy: float = 0.6

@export_group("Transition Settings")
@export var transition_duration: float = 0.6
@export var smooth_sky_transition: bool = true
@export var smooth_fog_transition: bool = true
@export var smooth_exposure_transition: bool = true

@export_group("Node References")
@export var directional_light: DirectionalLight3D
@export var transition_overlay: CanvasLayer

@onready var world_environment: WorldEnvironment = _find_or_create_world_environment()

var tween: Tween
var current_dimension: int = -1

func _ready():
    # Connect to the global manager
    DimensionManager.dimension_changed.connect(_on_dimension_changed)

    # Set initial state (instant, no transition on startup)
    current_dimension = DimensionManager.current_dimension
    _apply_atmosphere_instant(DimensionManager.current_dimension)

func _on_dimension_changed(new_dim):
    if new_dim == current_dimension:
        return

    _transition_atmosphere(new_dim)
    current_dimension = new_dim

func _transition_atmosphere(target_dim: int):
    if not world_environment or not world_environment.environment:
        push_error("AtmosphereManager: WorldEnvironment not found!")
        return

    var target_env = _get_environment_for_dimension(target_dim)
    if not target_env:
        push_error("AtmosphereManager: No environment for dimension ", target_dim)
        return

    # Kill any existing tween
    if tween:
        tween.kill()

    # Trigger shader overlay to peak at midpoint (0.3s)
    if transition_overlay:
        _trigger_overlay_transition()

    # Create new tween for smooth interpolation
    tween = create_tween()
    tween.set_parallel(true)  # All properties transition simultaneously
    tween.set_ease(Tween.EASE_IN_OUT)
    tween.set_trans(Tween.TRANS_CUBIC)

    var current_env = world_environment.environment

    # === ENVIRONMENT TRANSITIONS ===

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
        if target_env.fog_enabled:
            # Enable fog if not already enabled
            if not current_env.fog_enabled:
                current_env.fog_enabled = true
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
                tween.finished.connect(func(): current_env.fog_enabled = false)

    # Transition exposure/tonemap
    if smooth_exposure_transition:
        tween.tween_property(current_env, "tonemap_exposure",
            target_env.tonemap_exposure, transition_duration)

    # === DIRECTIONAL LIGHT TRANSITIONS ===

    if directional_light:
        var target_light_color = _get_light_color_for_dimension(target_dim)
        var target_light_energy = _get_light_energy_for_dimension(target_dim)

        tween.tween_property(directional_light, "light_color",
            target_light_color, transition_duration)
        tween.tween_property(directional_light, "light_energy",
            target_light_energy, transition_duration)

    print("AtmosphereManager: Transitioning to dimension ",
        DimensionManager.Dimension.keys()[target_dim], " over ", transition_duration, "s")

func _trigger_overlay_transition():
    # Call the transition overlay to animate shader effect
    # The overlay will peak at its midpoint (half of its duration)
    if transition_overlay.has_method("play_transition_with_duration"):
        transition_overlay.play_transition_with_duration(transition_duration)
    elif transition_overlay.has_method("_play_transition"):
        transition_overlay._play_transition()

func _apply_atmosphere_instant(dim: int):
    if not world_environment:
        return

    var env = _get_environment_for_dimension(dim)
    if env:
        world_environment.environment = env

    if directional_light:
        directional_light.light_color = _get_light_color_for_dimension(dim)
        directional_light.light_energy = _get_light_energy_for_dimension(dim)

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

func _get_light_color_for_dimension(dim: int) -> Color:
    match dim:
        DimensionManager.Dimension.NORMAL:
            return normal_light_color
        DimensionManager.Dimension.VIKING:
            return viking_light_color
        DimensionManager.Dimension.AZTEC:
            return aztec_light_color
        DimensionManager.Dimension.NIGHTMARE:
            return nightmare_light_color
    return Color.WHITE

func _get_light_energy_for_dimension(dim: int) -> float:
    match dim:
        DimensionManager.Dimension.NORMAL:
            return normal_light_energy
        DimensionManager.Dimension.VIKING:
            return viking_light_energy
        DimensionManager.Dimension.AZTEC:
            return aztec_light_energy
        DimensionManager.Dimension.NIGHTMARE:
            return nightmare_light_energy
    return 1.0

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
