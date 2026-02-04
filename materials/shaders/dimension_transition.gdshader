shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 multiplier : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float pixelation_amount : hint_range(1.0, 256.0) = 64.0;
uniform float aberration_strength : hint_range(0.0, 0.1) = 0.01;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// Pixelation effect
vec2 pixelate(vec2 uv, float amount) {
    vec2 pixel_size = vec2(1.0) / amount;
    return floor(uv / pixel_size) * pixel_size;
}

// Chromatic aberration with direction variation
vec4 chromatic_aberration(vec2 uv, float strength, float time) {
    // Add slight rotation to aberration direction based on time/intensity
    float angle = glitch_intensity * 6.28318; // Full rotation at max intensity
    vec2 direction = vec2(cos(angle), sin(angle));

    // Sample RGB channels with offset
    float r = texture(screen_texture, uv + direction * strength * glitch_intensity).r;
    float g = texture(screen_texture, uv).g;
    float b = texture(screen_texture, uv - direction * strength * glitch_intensity).b;

    return vec4(r, g, b, 1.0);
}

void fragment() {
    vec2 uv = SCREEN_UV;

    // Apply pixelation when glitch is active
    if (glitch_intensity > 0.01) {
        float pixel_amount = mix(1024.0, pixelation_amount, glitch_intensity);
        uv = pixelate(uv, pixel_amount);
    }

    // Get screen color with chromatic aberration
    vec4 screen_color;
    if (glitch_intensity > 0.01) {
        screen_color = chromatic_aberration(uv, aberration_strength, TIME);
    } else {
        screen_color = texture(screen_texture, uv);
    }

    // Apply color flash overlay
    vec4 flash_color = vec4(multiplier.rgb, progress);

    // Mix screen with flash based on progress
    COLOR = mix(screen_color, flash_color, progress * 0.5);

    // Add glitch distortion to alpha for additional visual noise
    COLOR.a = max(COLOR.a, glitch_intensity * 0.3);
}
