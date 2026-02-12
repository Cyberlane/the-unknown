# scripts/dimension_transition_overlay.gd
extends CanvasLayer

@export_group("Transition Settings")
@export var transition_duration: float = 1.0
@export var transition_shader: Shader

@export_group("Glitch Effect Settings")
@export var enable_glitch: bool = true
@export var glitch_duration: float = 0.2
@export var max_glitch_intensity: float = 0.8
@export var pixelation_amount: float = 64.0
@export var aberration_strength: float = 0.015

@onready var color_rect: ColorRect = $ColorRect
var shader_material: ShaderMaterial
var tween: Tween
var glitch_tween: Tween

# Dimension-specific colors for the transition flash
var dimension_colors = {
    DimensionManager.Dimension.NORMAL: Color(0.8, 0.8, 0.8, 1.0),
    DimensionManager.Dimension.VIKING: Color(0.2, 0.5, 0.9, 1.0),
    DimensionManager.Dimension.AZTEC: Color(0.9, 0.7, 0.2, 1.0),
    DimensionManager.Dimension.NIGHTMARE: Color(0.6, 0.1, 0.1, 1.0)
}

func _ready():
    # Set ColorRect to white (shader will control visibility)
    color_rect.color = Color.WHITE

    # Create shader material
    shader_material = ShaderMaterial.new()
    shader_material.shader = transition_shader
    shader_material.set_shader_parameter("progress", 0.0)
    shader_material.set_shader_parameter("multiplier", Color.WHITE)
    shader_material.set_shader_parameter("glitch_intensity", 0.0)
    shader_material.set_shader_parameter("pixelation_amount", pixelation_amount)
    shader_material.set_shader_parameter("aberration_strength", aberration_strength)

    # Apply to ColorRect
    color_rect.material = shader_material

    # Connect to dimension manager
    DimensionManager.dimension_changed.connect(_on_dimension_changed)

func _on_dimension_changed(new_dim):
    # Set the transition color based on target dimension
    var target_color = dimension_colors.get(new_dim, Color.WHITE)
    shader_material.set_shader_parameter("multiplier", target_color)

    # Animate the transition effect
    _play_transition()

# Public method to play transition with custom duration
func play_transition_with_duration(duration: float):
    _play_transition_internal(duration)

func _play_transition(duration: float = transition_duration):
    _play_transition_internal(duration)

func _play_transition_internal(duration: float):
    # Kill any existing tweens
    if tween:
        tween.kill()
    if glitch_tween:
        glitch_tween.kill()

    # Create new tween for progress
    tween = create_tween()
    tween.set_ease(Tween.EASE_IN_OUT)
    tween.set_trans(Tween.TRANS_CUBIC)

    # Animate progress: 0 → 1 → 0 (fade in, then fade out)
    tween.tween_method(_set_progress, 0.0, 1.0, duration / 2.0)
    tween.tween_method(_set_progress, 1.0, 0.0, duration / 2.0)

    # Trigger glitch effect at the peak (when progress = 1.0)
    if enable_glitch:
        # Wait until peak, then trigger glitch
        var delay_to_peak = duration / 2.0
        get_tree().create_timer(delay_to_peak).timeout.connect(_trigger_glitch)

func _trigger_glitch():
    # Create glitch intensity spike
    glitch_tween = create_tween()
    glitch_tween.set_ease(Tween.EASE_OUT)
    glitch_tween.set_trans(Tween.TRANS_BACK)

    # Spike up then down quickly
    glitch_tween.tween_method(_set_glitch_intensity, 0.0, max_glitch_intensity, glitch_duration / 2.0)
    glitch_tween.tween_method(_set_glitch_intensity, max_glitch_intensity, 0.0, glitch_duration / 2.0)

func _set_progress(value: float):
    shader_material.set_shader_parameter("progress", value)

func _set_glitch_intensity(value: float):
    shader_material.set_shader_parameter("glitch_intensity", value)
