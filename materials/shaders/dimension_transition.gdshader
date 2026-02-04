shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0
uniform vec4 multiplier : source_color = vec4(0.0, 0.0, 0.0, 1.0)

void fragment() {
    // Basic flash/fade effect - Claude should improve on this later
    vec4 screen_color = texture(TEXTURE, UV);
    COLOR = mix(screen_color, multiplier, progress);
}
