shader_type canvas_item;
render_mode unshaded, blend_add; // additive glow

// Driven from GDScript
uniform float fade : hint_range(0.0, 1.0) = 1.0;

// ------- Look & controls -------
uniform vec4  star_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float global_intensity : hint_range(0.0, 3.0) = 1.0;

// Twinkle shaping
uniform float speed     : hint_range(0.0, 10.0) = 1.2;
uniform float contrast  : hint_range(0.2, 4.0)  = 1.3;
uniform float variation : hint_range(0.0, 2.0)  = 1.0;

// Random seed
uniform float seed = 37.0;

// Layer A
uniform float cell_px_A   : hint_range(4.0, 128.0) = 28.0;
uniform float radius_px_A : hint_range(0.5, 4.0)   = 1.2;
uniform float density_A   : hint_range(0.0, 1.0)   = 0.35;
uniform float intensity_A : hint_range(0.0, 3.0)   = 0.9;

// Layer B
uniform float cell_px_B   : hint_range(8.0, 256.0) = 64.0;
uniform float radius_px_B : hint_range(0.5, 6.0)   = 2.2;
uniform float density_B   : hint_range(0.0, 1.0)   = 0.18;
uniform float intensity_B : hint_range(0.0, 3.0)   = 1.3;

// Cross-glow
uniform float cross_chance    : hint_range(0.0, 1.0) = 0.22;
uniform float cross_len_px    : hint_range(2.0, 64.0) = 18.0;
uniform float cross_thick_px  : hint_range(0.4, 10.0) = 1.2;
uniform float cross_intensity : hint_range(0.0, 4.0)  = 1.25;

// ------- Helpers -------
float hash11(float n) { return fract(sin(n) * 43758.5453123); }
vec2  hash22(vec2 p) {
    float n = sin(dot(p, vec2(127.1, 311.7)) + seed) * 43758.5453123;
    return vec2(fract(n), fract(n * 1.2154));
}

float star_layer(vec2 screen_px, float cell_px, float radius_px, float density, float layer_intensity) {
    vec2 cell_id = floor(screen_px / cell_px);

    vec2  rnd        = hash22(cell_id);
    float has_star   = step(1.0 - density, rnd.x);
    vec2  star_center = (cell_id + rnd.yx) * cell_px;

    vec2  d2   = screen_px - star_center;
    float d    = length(d2);
    float sigma = radius_px * 0.85;
    float base  = exp(- (d * d) / (2.0 * sigma * sigma));

    float phase = hash11(dot(cell_id, vec2(12.9898, 78.233)) + seed) * 6.2831853;
    float freq  = mix(0.8, 1.6, hash11(dot(cell_id, vec2(39.3467, 11.135)) + seed * 2.1));

    float s = sin(TIME * speed * freq + phase) * 0.5 + 0.5;
    float jitter = hash11(dot(cell_id, vec2(91.7, 15.3)) + TIME * 0.23 + seed * 3.7) - 0.5;
    s = clamp(s + jitter * 0.4 * variation, 0.0, 1.0);
    s = pow(s, contrast);

    float r_cross   = hash11(dot(cell_id, vec2(23.17, 59.21)) + seed * 4.3);
    float has_cross = step(1.0 - cross_chance, r_cross);

    float dx = d2.x;
    float dy = d2.y;
    float horiz = exp(- (dx * dx) / (2.0 * cross_len_px   * cross_len_px))
                * exp(- (dy * dy) / (2.0 * cross_thick_px * cross_thick_px));
    float vert  = exp(- (dy * dy) / (2.0 * cross_len_px   * cross_len_px))
                * exp(- (dx * dx) / (2.0 * cross_thick_px * cross_thick_px));
    float cross = has_cross * (horiz + vert) * cross_intensity;

    return has_star * (base + cross) * s * layer_intensity;
}

void fragment() {
    // Full-screen pixel coords so the field stays put
    vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 px = SCREEN_UV * screen_size;

    float a = star_layer(px, cell_px_A, radius_px_A, density_A, intensity_A);
    float b = star_layer(px, cell_px_B, radius_px_B, density_B, intensity_B);

    // Overall brightness
    float brightness = (a + b) * global_intensity;

    // Apply fade to brightness (works with additive blending)
    brightness *= fade;

    // Premultiply with star_color and scale by its alpha for intensity
    float alpha = clamp(brightness * star_color.a, 0.0, 1.0);
    vec3  rgb   = star_color.rgb * alpha;

    // With blend_add, RGB is what matters for visibility; alpha is fine to keep
    COLOR = vec4(rgb, alpha);
}
