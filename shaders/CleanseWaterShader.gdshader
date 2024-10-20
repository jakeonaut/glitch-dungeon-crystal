shader_type canvas_item;

void fragment() {
    vec3 screen_tex = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
    float average = (screen_tex.r + screen_tex.g + screen_tex.b) / 3.0;
    COLOR.rgb = vec3(average, average, average);
}