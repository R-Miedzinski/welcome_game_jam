shader_type spatial;

uniform sampler2D TEXTURE; // Declare the texture uniform

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    ALPHA = COLOR.a; // Use the vertex color's alpha channel
    ALBEDO = tex_color.rgb;
}