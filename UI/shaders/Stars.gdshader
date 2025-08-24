shader_type canvas_item;
render_mode unshaded; // ignore 2D lights

// --- Twinkle controls ---
uniform float speed       : hint_range(0.0, 10.0) = 1.2;
uniform float intensity   : hint_range(0.0, 2.0)  = 0.8;
uniform float variation   : hint_range(0.0, 2.0)  = 1.0;
uniform float contrast    : hint_range(0.2, 4.0)  = 1.3;

// Pixels below this alpha are ignored (don’t twinkle)
uniform float threshold   : hint_range(0.0, 1.0)  = 0.05;

// --- Pattern placement ---
// Size of a “star cell” in screen pixels (screen-space), and in UV space (texture-space).
// Use screen_weight to blend: 0 = UV-space only, 1 = SCREEN_UV only (default).
uniform float cell_px     : hint_range(2.0, 512.0) = 32.0;     // screen-space cell size, in pixels
uniform float cell_scale  : hint_range(8.0, 4096.0) = 320.0;   // UV-space cell density (fallback / blend)
uniform float screen_weight : hint_range(0.0, 1.0) = 1.0;

// Alpha follows brightness a bit to feel more “glinty”
uniform float alpha_mod   : hint_range(0.0, 1.0)  = 0.25;

// Randomization / tint
uniform float seed        = 37.0;
uniform vec3  tint        = vec3(1.0, 1.0, 1.0);

// --- Helpers ---
float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 34.345);
    return fract(p.x * p.y);
}

void fragment() {
    vec4 col = texture(TEXTURE, UV);

    // No early returns in Godot 4 fragment(); branch instead.
    if (col.a <= threshold) {
        COLOR = col;
    } else {
        // ---- Screen-space “cell” (stable to UV changes) ----
        // SCREEN_PIXEL_SIZE is 1 / screen_size_in_pixels.
        vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;          // e.g. (1920, 1080)
        vec2 screen_px   = SCREEN_UV * screen_size;          // current pixel coords
        vec2 sc_cell     = floor(screen_px / cell_px);       // screen-space cell id

        // ---- UV-space “cell” (classic, tied to texture UVs) ----
        vec2 uv_cell     = floor(UV * cell_scale);

        // Blend between them if desired
        vec2 cell = mix(uv_cell, sc_cell, screen_weight);

        // Per-star randomization from the chosen cell id
        float r0 = hash21(cell + seed);
        float r1 = hash21(cell + seed * 1.37);
        float phase = r0 * 6.2831853;     // 0..2π
        float freq  = mix(0.8, 1.6, r1);  // each cell flickers a bit differently

        // Base twinkle (0..1)
        float s = sin(TIME * speed * freq + phase) * 0.5 + 0.5;

        // Small noisy micro-variation so it’s not perfectly sinusoidal
        float r2 = hash21(cell + TIME * 0.23 + seed * 2.7);
        s = clamp(s + (r2 - 0.5) * 0.4 * variation, 0.0, 1.0);

        // Sharpen peaks (glintier)
        s = pow(s, contrast);

        // Map around 1.0 so stars both dim and brighten
        float gain = mix(1.0 - intensity, 1.0 + intensity, s);

        // Apply to color & (optionally) alpha
        vec3 base_rgb     = col.rgb * tint;
        vec3 twinkled_rgb = base_rgb * gain;
        float twinkled_a  = mix(col.a, col.a * gain, alpha_mod);

        COLOR = vec4(twinkled_rgb, twinkled_a);
    }
}
