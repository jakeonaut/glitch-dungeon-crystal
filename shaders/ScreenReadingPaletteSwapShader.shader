shader_type canvas_item;
uniform sampler2D screen_texture : hint_albedo;
uniform sampler2D base_palette : hint_albedo;

void fragment() {
    vec3 screen_tex = texture(screen_texture, vec2(1.0)).rgb;
    // https://gamedev.stackexchange.com/questions/43294/creating-a-retro-style-palette-swapping-effect-in-opengl
    vec2 index = vec2(mod(screen_tex.r*256.0, 16.0)/16.0, 0);
    vec4 indexed_color = texture(base_palette, index, -100);
    COLOR.rgb = indexed_color.rgb; // vec3(index.x); // indexed_color.rgb;
    // Brain Blast: even though sampling the r value from the output on paint for "black" background results in rgb = 4,0,0
    // the r value is actually represented in shader code as (4/256) or ~0.015625
    // Therefore (mod(r, 8)) doesn't output "4" as expected, but actually ~0.015625
    // What we need to do is multiply r by 256
    // mod(screen_tex.r*256.0, 8.0)/8.0
}