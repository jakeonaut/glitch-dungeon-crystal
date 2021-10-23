shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,unshaded;
uniform sampler2D texture_albedo : hint_albedo;
uniform sampler2D base_palette : hint_albedo;

uniform int palettesize = 16;

void vertex() {
    UV=UV*vec3(3, 2, 3).xy+vec3(0, 0, 0).xy;
}

// int getpaletteidx(vec3 color) {
//     for (int x=0; x<palettesize; x++) {
//         ivec2 coord = ivec2(x,0);
//         vec3 pixelcolor = texelFetch(base_palette, coord, 0).rgb;    
//         if (distance(color, pixelcolor) == 0.0) {
//             return x;
//         }
//     }
//     return -1;
// }

// vec3 getpalettecolor(int x) {
//     ivec2 coord = ivec2(x,0);
//     return texelFetch(target_palette, coord, 0).rgb;
// }

void fragment() {    
    vec2 base_uv = UV;
    vec4 albedo_tex = texture(texture_albedo, base_uv);
    // https://gamedev.stackexchange.com/questions/43294/creating-a-retro-style-palette-swapping-effect-in-opengl
    vec2 index = vec2(albedo_tex.r*225.0, 0); // I have no idea why we have to multiply by 500.
    // vec2 index = vec2(mod(albedo_tex.r*256.0, 16.0)/16.0, 0);
    vec4 indexed_color = texture(base_palette, index, -100);
    ALBEDO = indexed_color.rgb;
}
