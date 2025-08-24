shader_type canvas_item;
render_mode unshaded, blend_disabled;

// Godot 4.4+: declare the screen texture explicitly.
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;

// -------- Center for the vignette (UV) --------
uniform vec2 center = vec2(0.5, 0.5);

// -------- Vignette-Blur Controls --------
// Where the blur starts (0=center .. ~1=edge)
uniform float vig_radius   : hint_range(0.0, 1.5) = 0.85;
// Width of the falloff to full blur
uniform float vig_softness : hint_range(0.001, 1.0) = 0.35;
// Shape the falloff curve (1 = default)
uniform float vig_power    : hint_range(0.5, 4.0) = 1.5;
// Blur radius in pixels at full effect
uniform float vig_blur_px  : hint_range(0.0, 12.0) = 3.0;
// Blend amount at full effect (0 = off, 1 = full blur)
uniform float vig_strength : hint_range(0.0, 1.0) = 0.6;
// 8 taps (diagonals) for nicer blur if you have GPU headroom
uniform bool  vig_high_quality = false;

// ---------- Helper ----------
vec3 tex_rgb(vec2 u) {
    return texture(SCREEN_TEXTURE, clamp(u, vec2(0.0), vec2(1.0))).rgb;
}

void fragment() {
    vec2 uv = SCREEN_UV;

    // Aspect-correct radial distance from center
    vec2 d_uv = uv - center;
    float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x; // width/height
    vec2 d_aspect = vec2(d_uv.x * aspect, d_uv.y);
    float r = length(d_aspect);

    // Vignette mask -> smooth edge-only weight
    float t  = clamp((r - vig_radius) / max(vig_softness, 1e-6), 0.0, 1.0);
    float w  = t * t * (3.0 - 2.0 * t);          // smoothstep
    w = pow(w, vig_power);                        // shape
    float blur_w = vig_strength * w;              // final blend weight

    // Base color
    vec3 base = tex_rgb(uv);
    vec3 col = base;

    // Only blur if needed
    if (vig_blur_px > 0.0 && blur_w > 0.0) {
        vec2 o = SCREEN_PIXEL_SIZE * (vig_blur_px * blur_w);

        // 4 axial taps
        vec3 s0 = tex_rgb(uv + vec2( o.x, 0.0));
        vec3 s1 = tex_rgb(uv + vec2(-o.x, 0.0));
        vec3 s2 = tex_rgb(uv + vec2(0.0,  o.y));
        vec3 s3 = tex_rgb(uv + vec2(0.0, -o.y));

        vec3 blur_col;
        if (vig_high_quality) {
            // Add 4 diagonal taps for a cleaner kernel
            vec2 od = o * 0.70710678; // 1/sqrt(2)
            vec3 s4 = tex_rgb(uv + vec2( od.x,  od.y));
            vec3 s5 = tex_rgb(uv + vec2(-od.x,  od.y));
            vec3 s6 = tex_rgb(uv + vec2( od.x, -od.y));
            vec3 s7 = tex_rgb(uv + vec2(-od.x, -od.y));
            blur_col = (s0 + s1 + s2 + s3 + s4 + s5 + s6 + s7) * (1.0 / 8.0);
        } else {
            blur_col = (s0 + s1 + s2 + s3) * 0.25;
        }

        // Mix blurred edges over the original image according to the vignette weight
        col = mix(base, blur_col, blur_w);
    }

    COLOR = vec4(col, 1.0);
}
