shader_type canvas_item;
render_mode unshaded, blend_add;

// Godot 4.4+: explicit screen sampler
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// ---- Controls ----
uniform float threshold  : hint_range(0.0, 4.0) = 1.0; // brightness cutoff
uniform float soft_knee  : hint_range(0.0, 1.0) = 0.5; // soften the cutoff
uniform float radius_px  : hint_range(1.0, 64.0) = 16.0; // blur radius in pixels
uniform float strength   : hint_range(0.0, 3.0)  = 1.0;  // overall intensity
uniform vec3  tint       : source_color = vec3(1.0);     // bloom tint

// Quality/perf knobs
const int DIRS  = 12; // angular taps
const int RINGS = 3;  // radial taps per direction

float luma(vec3 c) { return dot(c, vec3(0.2126, 0.7152, 0.0722)); }

vec3 extract_bright(vec3 c) {
    float L = luma(c);
    float knee = threshold * soft_knee + 1e-5;
    float w = smoothstep(threshold - knee, threshold + knee, L);
    return c * w;
}

vec3 sample_bright(vec2 uv) {
    return extract_bright(texture(SCREEN_TEXTURE, uv).rgb);
}

void fragment() {
    vec2 uv = SCREEN_UV;

    // Convert pixel radius to UV space
    vec2 texel = SCREEN_PIXEL_SIZE * radius_px;

    // Gather bright regions around the pixel (looped blur)
    vec3 acc = sample_bright(uv);
    float count = 1.0;

    for (int d = 0; d < DIRS; d++) {
        float a = (float(d) / float(DIRS)) * 6.28318530718; // 2π
        vec2 dir = vec2(cos(a), sin(a));
        for (int r = 1; r <= RINGS; r++) {
            float t = float(r) / float(RINGS);
            vec2 off = dir * texel * t;
            acc += sample_bright(uv + off);
            count += 1.0;
        }
    }

    vec3 bloom = (acc / count) * strength * tint;
    COLOR = vec4(bloom, 1.0); // additive overlay
}
