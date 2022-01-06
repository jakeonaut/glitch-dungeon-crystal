shader_type canvas_item;
render_mode blend_mix,unshaded;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform sampler2D base_palette : hint_albedo;
uniform sampler2D target_palette : hint_albedo;

// æŒ¯å‹•ã®å¼·ã•
uniform float shake_power = 0.03;
// æŒ¯å‹•ãƒ–ãƒ­ãƒƒã‚¯ã‚µã‚¤ã‚º
uniform float shake_block_size = 30.5;
// è‰²ã®åˆ†é›¢çŽ‡
uniform float shake_color_rate : hint_range( 0.0, 1.0 ) = 0.01;

uniform int palettesize = 16;
uniform bool enable_glitch = false;

int getpaletteidx(vec3 color) {
    for (int x=0; x<palettesize; x++) {
        ivec2 coord = ivec2(x,0);
        vec3 pixelcolor = texelFetch(base_palette, coord, 0).rgb;    
        if (distance(color, pixelcolor) == 0.0) {
            return x;
        }
    }
    return -1;
}

vec3 getpalettecolor(int x) {
    ivec2 coord = ivec2(x,0);
    return texelFetch(target_palette, coord, 0).rgb;
}

float random(float seed) {
	return fract(543.2543 * sin(dot(vec2(seed, seed), vec2(3525.46, -54.3415))));
}

void fragment() {
    vec4 incolor = texture(texture_albedo, UV);
     
    int index = getpaletteidx(incolor.rgb);
     
    float fdelta = float(index); // - TIME * 10.0;
    float mod2 = mod(fdelta,float(palettesize));
    int delta = int(mod2);
     
    vec3 color = getpalettecolor(delta);
     
    if (index > -1) {
        COLOR.rgb = color.rgb;  
    }
    else {
        COLOR.rgb = vec3(0,1,0);
    }
    COLOR.a = incolor.a;

	if (enable_glitch) {
		vec2 fixed_uv = UV;
		fixed_uv.x += (random((trunc(COLOR.y * shake_block_size) / shake_block_size) + TIME) - 0.5) * shake_power;
		fixed_uv.y += (random((trunc(COLOR.y * shake_block_size) / shake_block_size) + TIME) - 0.5) * shake_power;
		
		vec4 alp = texture(texture_albedo, fixed_uv);

		color.r = mix(color.r, texture(texture_albedo, fixed_uv + vec2(shake_color_rate, 0.0)).r, 0.5);
		color.b = mix(color.b, texture(texture_albedo, fixed_uv + vec2(-shake_color_rate, 0.0)).b, 0.5);
		COLOR.rgb = color.rgb;
		COLOR.a = alp.a;
	}
}