shader_type spatial;
render_mode blend_mix,depth_draw_alpha_prepass,cull_disabled,diffuse_burley,specular_schlick_ggx,unshaded;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform sampler2D base_palette : hint_albedo;
uniform sampler2D target_palette : hint_albedo;

uniform int palettesize = 16;

void vertex() {
    UV=UV*vec3(1, 1, 1).xy+vec3(0, 0, 0).xy;
    MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat4(CAMERA_MATRIX[0],CAMERA_MATRIX[1],CAMERA_MATRIX[2],WORLD_MATRIX[3]);
}

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

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
    vec4 incolor = texture(texture_albedo, UV);
    int index = getpaletteidx(incolor.rgb);
    float fdelta = float(index) - TIME * 5.0;
    float mod2 = 8.0 + mod(fdelta, float(5));
    int delta = int(mod2);
    vec3 color = getpalettecolor(delta);
    if (index > -1) {
        ALBEDO.rgb = color.rgb;  
    }
    else {
        ALBEDO.rgb = vec3(0,1,0);
    }
    ALPHA = incolor.a;
}