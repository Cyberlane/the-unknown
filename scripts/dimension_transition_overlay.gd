# scripts/dimension_transition_overlay.gd
extends CanvasLayer

@export var transition_duration: float = 0.3
@export var transition_shader: Shader

@onready var color_rect: ColorRect = $ColorRect
var shader_material: ShaderMaterial
var tween: Tween

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

func _play_transition():
    # Kill any existing tween
    if tween:
        tween.kill()

    # Create new tween
    tween = create_tween()
    tween.set_ease(Tween.EASE_IN_OUT)
    tween.set_trans(Tween.TRANS_CUBIC)

    # Animate progress: 0 → 1 → 0 (fade in, then fade out)
    tween.tween_method(_set_progress, 0.0, 1.0, transition_duration / 2.0)
    tween.tween_method(_set_progress, 1.0, 0.0, transition_duration / 2.0)

func _set_progress(value: float):
    shader_material.set_shader_parameter("progress", value)
