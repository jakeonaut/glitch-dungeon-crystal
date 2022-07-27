//---CRT Shader---
shader_type canvas_item;

uniform int color_depth : hint_range(1, 8) = 5;
uniform bool dithering = true;
uniform int resolution_scale = 4;
uniform float r_mult = 0.0;
uniform float g_mult = 1.0;
uniform float b_mult = -1.0;

int dithering_pattern(ivec2 fragcoord) {
    const int pattern[] = {
        -4, +0, -3, +1, 
        +2, -2, +3, -1, 
        -3, +1, -4, +0, 
        +3, -1, +2, -2
    };
    
    int x = fragcoord.x % 4;
    int y = fragcoord.y % 4;
    
    return pattern[y * 4 + x];
}

vec2 uv_curve(vec2 uv)
{
    uv = (uv - 0.5) * 2.0;
    
    //You can modify the numbers and try different values
    uv.x *= 1.0 + pow(abs(uv.y) / 3.0, 2.0);
    uv.y *= 1.0 + pow(abs(uv.x) / 3.0, 2.0);
    
    //The scale part (you can delete it when you want)
    uv /= 1.2;
    
    uv = (uv/2.0) + 0.5;
    return uv;
}


void fragment()
{   
    float PI = 3.14159;
        
    // // You can modify the *3.0, *-3.0 for a bigger or smaller 
    float r = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE.x*r_mult), 0.0).r;
    float g = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE.x*g_mult), 0.0).g;
    float b = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE.x*b_mult), 0.0).b;
    
    COLOR = vec4(r, g, b, 1.0);


    // ivec2 uv = ivec2(FRAGCOORD.xy / float(resolution_scale));
    // vec3 color = texelFetch(SCREEN_TEXTURE, uv * resolution_scale, 0).rgb;
    
    // // Convert from [0.0, 1.0] range to [0, 255] range
    // ivec3 c = ivec3(round(color * 255.0));
    
    // // Apply the dithering pattern
    // if (dithering) {
    //  c += ivec3(dithering_pattern(uv));
    // }
    
    // // Truncate from 8 bits to color_depth bits
    // c >>= (8 - color_depth);

    // // Convert back to [0.0, 1.0] range
    // vec3 albedo = vec3(c) / float(1 << color_depth);
    // COLOR = vec4(albedo.r, albedo.g, albedo.b, 1.0);
}
