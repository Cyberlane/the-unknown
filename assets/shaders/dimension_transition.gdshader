shader_type canvas_item;

uniform sampler2D transition_texture : hint_albedo;
uniform float progress : hint_range(0, 1) = 0.5;

void fragment() {
    vec2 uv = FRAGCOORD.xy / SCREEN_PIXEL_SIZE.xy;
    vec4 color = texture(TEXTURE, uv);
    
    if (progress < 0.5) {
        // Dissolve effect from left to right
        float dissolve_factor = smoothstep(0.0, 1.0, progress * 2.0);
        color.a *= step(dissolve_factor, uv.x / SCREEN_PIXEL_SIZE.x);
    } else {
        // Dissolve effect from right to left
        float dissolve_factor = smoothstep(0.0, 1.0, (progress - 0.5) * 2.0);
        color.a *= step(uv.x / SCREEN_PIXEL_SIZE.x, 1.0 - dissolve_factor);
    }
    
    COLOR = color;
}
