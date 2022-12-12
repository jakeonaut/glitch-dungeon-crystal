shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,unshaded;
uniform sampler2D texture_albedo : hint_albedo;
uniform sampler2D base_palette : hint_albedo;
uniform sampler2D real_base_palette : hint_albedo;

uniform int palettesize = 16;

void vertex() {
    UV=UV*vec3(3, 2, 3).xy+vec3(0, 0, 0).xy;
}

vec3 getpalettecolor(int x) {
    ivec2 coord = ivec2(x,0);
    return texelFetch(real_base_palette, coord, 0).rgb;
}

float Convert_sRGB_FromLinear (float theLinearValue) {
  return theLinearValue <= 0.0031308
       ? theLinearValue * 12.92
       : pow (theLinearValue, 1.0/2.4) * 1.055 - 0.055;
}

float random(float seed) {
	return fract(543.2543 * sin(dot(vec2(seed, seed), vec2(3525.46, -54.3415))));
}

float random2( vec2 p )
{
  // We need irrationals for pseudo randomness.
  // Most (all?) known transcendental numbers will (generally) work.
  const vec2 r = vec2(
    23.1406926327792690,  // e^pi (Gelfond's constant)
     2.6651441426902251); // 2^sqrt(2) (Gelfond–Schneider constant)
  return fract( cos( mod( 123456789., 1e-7 + 256. * dot(p,r) ) ) );  
}

void fragment() {
    vec4 incolor = texture(texture_albedo, UV);
    float fdelta = mod(256.0 * Convert_sRGB_FromLinear(incolor.r), 16.0) - TIME * random(1.0);
    float mod2 = mod(fdelta, float(palettesize));
    int delta = int(mod2);
    vec3 color = getpalettecolor(delta);
    ALBEDO.rgb = color.rgb;
    ALPHA = incolor.a;
}
