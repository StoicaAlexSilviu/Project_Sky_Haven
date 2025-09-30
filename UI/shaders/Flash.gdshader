shader_type canvas_item;

// NEW in 4.4: explicitly declare the screen texture
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Color of the flash (RGB) and its base opacity (A)
uniform vec4 flash_color : source_color = vec4(1.0, 0.95, 0.7, 1.0);

// How strong the flash is right now (animate 1.0 -> 0.0 to fade)
uniform float flash_strength : hint_range(0.0, 1.0) = 0.0;

// Thickness of the edge band (0.0–0.5)
uniform float edge_width = 0.08;

// Softness of the inner falloff
uniform float edge_softness = 0.08;

// Optional ease for the fade
uniform float flash_gamma = 1.0;

// >1.0 weights corners a bit more (vignette-like)
uniform float corner_bias = 1.0;

void fragment() {
    // Sample the rendered scene behind this ColorRect
    vec4 scene = texture(SCREEN_TEXTURE, SCREEN_UV);

    // Distance to nearest screen edge in UV space
    float d = min(min(UV.x, UV.y), min(1.0 - UV.x, 1.0 - UV.y));

    // Optional corner bias
    if (corner_bias > 1.0) {
        vec2 p = UV * 2.0 - 1.0; // [-1,1]
        float r = pow(length(p), corner_bias);
        d = mix(d, d * (1.0 - r), 0.5);
    }

    // Edge mask (1 at border → 0 inward), feathered by edge_softness
    float edge = 1.0 - smoothstep(edge_width, edge_width + edge_softness, d);

    // Flash amount
    float amt = pow(clamp(flash_strength, 0.0, 1.0), flash_gamma) * edge * flash_color.a;

    // Mix scene toward flash color (additive-ish but controlled)
    vec3 out_rgb = mix(scene.rgb, flash_color.rgb, amt);

    COLOR = vec4(out_rgb, 1.0);
}
