// Godot 4.4.1 — 2D overlay color with opacity
// Affected by CanvasModulate and other canvas lighting.

shader_type canvas_item;

// Overlay tint, with alpha controlling strength.
uniform vec4 overlay_color : source_color = vec4(1.0, 0.2, 0.0, 0.5);

void fragment() {
    vec4 base = texture(TEXTURE, UV);

    // Mix overlay with base color *inside the visible sprite alpha*.
    vec3 mixed_rgb = mix(base.rgb, overlay_color.rgb, overlay_color.a);

    // Keep sprite's original alpha (so transparency is preserved).
    COLOR = vec4(mixed_rgb, base.a);
}
