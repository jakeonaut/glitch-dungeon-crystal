shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,unshaded;
uniform sampler2D texture_albedo : hint_albedo;
uniform sampler2D base_palette : hint_albedo;

uniform int palettesize = 16;

void vertex() {
    UV=UV*vec3(3, 2, 3).xy+vec3(0, 0, 0).xy;
}

vec3 getpalettecolor(int x) {
    ivec2 coord = ivec2(x,0);
    return texelFetch(base_palette, coord, 0).rgb;
}

float Convert_sRGB_FromLinear (float theLinearValue) {
  return theLinearValue <= 0.0031308
       ? theLinearValue * 12.92
       : pow (theLinearValue, 1.0/2.4) * 1.055 - 0.055;
}

void fragment() {
    vec4 incolor = texture(texture_albedo, UV);
    float fdelta = mod(256.0 * Convert_sRGB_FromLinear(incolor.r), 16.0) - TIME * 10.0;
    float mod2 = mod(fdelta, float(palettesize));
    int delta = int(mod2);
    vec3 color = getpalettecolor(delta);
    ALBEDO.rgb = color.rgb;
    ALPHA = incolor.a;
}
