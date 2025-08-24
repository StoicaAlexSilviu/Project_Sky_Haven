shader_type canvas_item;
render_mode unshaded, blend_disabled;

// Godot 4.4+: screen texture must be declared explicitly.
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;

// -------- Chromatic Aberration Controls --------
uniform vec2  center = vec2(0.5, 0.5);           // effect center (UV)
uniform float inner  : hint_range(0.0, 1.0) = 0.0;
uniform float radius : hint_range(0.05, 1.5) = 0.95;
uniform float strength_px : hint_range(0.0, 12.0) = 3.0;
uniform float green_shift  : hint_range(-1.0, 1.0) = 0.0;
uniform bool  early_out = true;

// -------- Static Colored Grain Controls --------
uniform float grain_amount   : hint_range(0.0, 1.0) = 0.08; // 0 disables
uniform float grain_size_px  : hint_range(1.0, 12.0) = 2.0; // 1 = per-pixel
uniform float grain_contrast : hint_range(0.5, 2.0) = 1.0;  // shaping
uniform float grain_seed     : hint_range(0.0, 1000.0) = 0.0;
uniform bool  grain_colored = true;

// ---------- Noise helpers (for static grain) ----------
// Stable non-directional hash (IQ-style)
vec3 hash23(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xxy + p3.yzz) * p3.zyx);
}

// 2D value noise (3 channels) – smooth, tileable per cell
vec3 value_noise23(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);

    vec3 a = hash23(i + vec2(0.0, 0.0));
    vec3 b = hash23(i + vec2(1.0, 0.0));
    vec3 c = hash23(i + vec2(0.0, 1.0));
    vec3 d = hash23(i + vec2(1.0, 1.0));

    vec3 ab = mix(a, b, u.x);
    vec3 cd = mix(c, d, u.x);
    return mix(ab, cd, u.y);
}

void fragment() {
    vec2 uv = SCREEN_UV;

    // -------- Radial metrics (aspect-correct) --------
    vec2 d_uv = uv - center;
    float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x; // width/height
    vec2 d_aspect = vec2(d_uv.x * aspect, d_uv.y);
    float dist2 = dot(d_aspect, d_aspect);

    // -------- Chromatic aberration --------
    float inner2 = inner * inner;
    float radius2 = radius * radius;
    float denom = max(radius2 - inner2, 1e-6);
    float t = clamp((dist2 - inner2) / denom, 0.0, 1.0);
    float ca_mask = t * t * (3.0 - 2.0 * t); // smoothstep

    vec3 base = texture(SCREEN_TEXTURE, uv).rgb;
    vec3 col;

    if (early_out && ca_mask <= 0.0) {
        col = base;
    } else {
        // Direction in pixel space (no VIEWPORT_SIZE dependency)
        vec2 delta_px = d_uv / SCREEN_PIXEL_SIZE;
        float len2 = max(dot(delta_px, delta_px), 1e-6);
        vec2 dir_px = delta_px * inversesqrt(len2);

        // Pixel -> UV offset
        vec2 uv_offset = dir_px * (strength_px * ca_mask) * SCREEN_PIXEL_SIZE;

        vec2 uv_r = uv + uv_offset;
        vec2 uv_b = uv - uv_offset;
        vec2 uv_g = uv + uv_offset * green_shift;

        float rch = texture(SCREEN_TEXTURE, clamp(uv_r, vec2(0.0), vec2(1.0))).r;
        float bch = texture(SCREEN_TEXTURE, clamp(uv_b, vec2(0.0), vec2(1.0))).b;
        float gch = (abs(green_shift) < 1e-5)
                  ? base.g
                  : texture(SCREEN_TEXTURE, clamp(uv_g, vec2(0.0), vec2(1.0))).g;

        col = vec3(rch, gch, bch);
    }

    // -------- Static colored grain --------
    if (grain_amount > 0.0) {
        vec2 pix = uv / SCREEN_PIXEL_SIZE; // pixel coords
        vec2 p = (pix / max(grain_size_px, 1.0)) + vec2(grain_seed, grain_seed * 1.37);

        vec3 n3 = value_noise23(p);
        vec3 noise = grain_colored ? n3 : vec3(n3.r);

        noise = (noise - 0.5) * 2.0;                        // [-1,1]
        noise = sign(noise) * pow(abs(noise), vec3(grain_contrast));
        col = clamp(col + noise * grain_amount, 0.0, 1.0);
    }

    COLOR = vec4(col, 1.0);
}
