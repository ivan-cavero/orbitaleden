// Radial vignette + full-screen fade overlay.
// Driven by screen_effects.gd via uniforms.
shader_type canvas_item;

/// Vignette strength at screen edges. 0 = none, 1 = dark edges.
uniform float vignette_intensity: hint_range(0.0, 1.0) = 0.0;

/// Full-screen fade (0 = transparent, 1 = fully opaque over the scene).
uniform float fade_intensity: hint_range(0.0, 1.0) = 0.0;

/// Color used for the full-screen fade (black for unconsciousness).
uniform vec4 fade_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);

/// Color used for the vignette (black by default).
uniform vec4 vignette_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	// ── Vignette ──────────────────────────────────────────────────────────────
	vec2 uv = UV - vec2(0.5);
	float dist = clamp(dot(uv, uv) * 2.828, 0.0, 1.0);
	float vignette = smoothstep(0.3, 1.0, dist) * vignette_intensity;

	// ── Composite: vignette first, then fade on top ───────────────────────────
	vec4 vig_layer  = vec4(vignette_color.rgb, vignette);
	vec4 fade_layer = vec4(fade_color.rgb,     fade_intensity);

	// Alpha-blend fade on top of vignette.
	float out_a   = fade_layer.a + vig_layer.a * (1.0 - fade_layer.a);
	vec3  out_rgb = (fade_layer.rgb * fade_layer.a + vig_layer.rgb * vig_layer.a * (1.0 - fade_layer.a));
	if (out_a > 0.0) out_rgb /= out_a;

	COLOR = vec4(out_rgb, out_a);
}
