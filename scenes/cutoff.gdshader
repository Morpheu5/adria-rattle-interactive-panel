shader_type spatial;
uniform sampler2D _albedo: source_color;

void fragment() {
	ALBEDO = texture(_albedo, UV).rgb;
}
