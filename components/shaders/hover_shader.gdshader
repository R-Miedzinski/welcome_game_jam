shader_type canvas_item;

uniform vec4 overlay_color;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    COLOR = mix(tex_color, overlay_color, overlay_color.a);
}