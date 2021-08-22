shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,unshaded;
uniform sampler2D texture_albedo : hint_albedo;
uniform sampler2D base_palette : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_metallic : hint_white;
uniform sampler2D texture_roughness : hint_white;

void vertex() {
	UV=UV*vec3(3, 2, 3).xy+vec3(0, 0, 0).xy;
}

void fragment() {    
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo, base_uv);
    // https://gamedev.stackexchange.com/questions/43294/creating-a-retro-style-palette-swapping-effect-in-opengl
    vec2 index = vec2(albedo_tex.r*450.0, 0); // I have no idea why we have to multiply by 500.
    vec4 indexed_color = texture(base_palette, index, -100);
	ALBEDO = indexed_color.rgb;
	float metallic_tex = dot(texture(texture_metallic,base_uv),vec4(1,0,0,0));
	METALLIC = metallic_tex * metallic;
	float roughness_tex = dot(texture(texture_roughness,base_uv),vec4(1,0,0,0));
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
}
