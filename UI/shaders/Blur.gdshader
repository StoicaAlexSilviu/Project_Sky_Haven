shader_type canvas_item;

// Screen copy (Godot 4.x pattern)
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

uniform float blur_radius_px = 6.0;   // max blur radius (pixels)
uniform float edge_width     = 0.18;  // blurred border thickness (0..0.5 of screen)
uniform float edge_softness  = 0.10;  // feather between edge and center
uniform float intensity      = 1.0;   // overall effect strength

vec4 sample_screen(vec2 uv) {
    return texture(SCREEN_TEXTURE, clamp(uv, vec2(0.0), vec2(1.0)));
}

vec2 texel_size() {
    // Size in pixels of the screen copy
    ivec2 sz = textureSize(SCREEN_TEXTURE, 0);
    return 1.0 / vec2(max(float(sz.x), 1.0), max(float(sz.y), 1.0));
}

// 9-tap blur using pixel radius (converted to UV via texel_size)
vec4 blur9(vec2 uv, float px_radius) {
    vec2 step_uv = texel_size() * max(px_radius, 0.0001);

    vec4 c = vec4(0.0);
    c += sample_screen(uv) * 0.28;
    c += sample_screen(uv + vec2( 1.0,  0.0) * step_uv) * 0.09;
    c += sample_screen(uv + vec2(-1.0,  0.0) * step_uv) * 0.09;
    c += sample_screen(uv + vec2( 0.0,  1.0) * step_uv) * 0.09;
    c += sample_screen(uv + vec2( 0.0, -1.0) * step_uv) * 0.09;

    float d = 0.70710678;
    c += sample_screen(uv + vec2( d,  d) * step_uv) * 0.09;
    c += sample_screen(uv + vec2(-d,  d) * step_uv) * 0.09;
    c += sample_screen(uv + vec2( d, -d) * step_uv) * 0.09;
    c += sample_screen(uv + vec2(-d, -d) * step_uv) * 0.09;
    return c;
}

void fragment() {
    vec2 uv = SCREEN_UV;

    // Distance to nearest edge (0 at edge, ~0.5 at center)
    float d_to_edge = min(min(uv.x, uv.y), min(1.0 - uv.x, 1.0 - uv.y));

    // 1 at edges → 0 toward center
    float mask = 1.0 - smoothstep(edge_width, edge_width + edge_softness, d_to_edge);
    mask *= intensity;

    vec4 base_col = sample_screen(uv);
    vec4 blur_col = blur9(uv, blur_radius_px * mask);

    COLOR = mix(base_col, blur_col, mask);
}
