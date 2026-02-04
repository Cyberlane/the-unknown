shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 multiplier : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    // Flash effect with alpha fade
    // When progress is 0, the overlay is fully transparent
    // When progress is 1, the overlay shows the multiplier color
    COLOR = vec4(multiplier.rgb, progress);
}
