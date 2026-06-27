shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 0.9, 0.0, 1.0);
uniform float outline_width : hint_range(0.0, 20.0) = 3.0;
uniform float glow_intensity : hint_range(0.0, 5.0) = 2.0;
uniform float pulse_speed : hint_range(0.0, 10.0) = 2.0;
uniform int glow_samples : hint_range(1, 16) = 8;
uniform bool enabled = false;

void fragment() {
	vec4 current_color = texture(TEXTURE, UV);

	if (enabled) {
		vec2 tex_size = vec2(textureSize(TEXTURE, 0));
		float alpha = 0.0;

		for (int i = 0; i < glow_samples; i++) {
			float angle = float(i) * TAU / float(glow_samples);
			vec2 offset = vec2(cos(angle), sin(angle)) * outline_width / tex_size;
			alpha = max(alpha, texture(TEXTURE, UV + offset).a);

			vec2 offset2 = vec2(cos(angle), sin(angle)) * (outline_width * 2.0) / tex_size;
			alpha = max(alpha, texture(TEXTURE, UV + offset2).a * 0.5);
		}

		float pulse = (sin(TIME * pulse_speed) * 0.5 + 0.5);
		float final_intensity = 1.0 + pulse * glow_intensity;
		vec4 outline = vec4(outline_color.rgb * final_intensity, outline_color.a * alpha);
		COLOR = mix(outline, current_color, current_color.a);
	} else {
		COLOR = current_color;
	}
}