shader_type canvas_item;

void fragment() {
    vec3 screen_tex = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
    COLOR.rgb = vec3(screen_tex.r/2.0, screen_tex.g, screen_tex.b + screen_tex.r);
}