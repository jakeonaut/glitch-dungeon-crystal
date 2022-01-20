shader_type canvas_item;
uniform sampler2D base_palette : hint_albedo;
uniform sampler2D target_palette : hint_albedo;
uniform int palettesize = 16;

uniform int color_depth : hint_range(1, 8) = 8;
uniform int resolution_scale = 4;
uniform float ratio_multiplier = 1.0;

const int bayer[] = {
 0,32, 8,40, 2,34,10,42,
48,16,56,24,50,18,58,26, 
12,44, 4,36,14,46, 6,38, 
60,28,52,20,62,30,54,22, 
 3,35,11,43, 1,33, 9,41, 
51,19,59,27,49,17,57,25,
15,47, 7,39,13,45, 5,37,
63,31,55,23,61,29,53,21
}; 
const float bayerSize = 8.0;
const float bayerDivider = bayerSize * bayerSize;

const int matrix[] = {
    1, 9, 3, 11,
    13, 5, 15, 7,
    4, 12, 2, 10,
    16, 8, 14, 6
};
const float matrixSize = 4.0;

int getclosestpaletteidx(ivec3 color) {
    float closest_distance = 999.0;
    int closest_x = 0;
    for (int x=0; x<palettesize; x++) {
        ivec2 coord = ivec2(x,0);
        vec3 pixelcolor = texelFetch(target_palette, coord, 0).rgb;
        ivec3 ipixelcolor = ivec3(round(pixelcolor * 255.0));
        float the_distance = distance(vec3(color), vec3(ipixelcolor));
        if (the_distance < closest_distance) {
            closest_distance = the_distance;
            closest_x = x;
        }
    }
    return closest_x;
}

vec3 getpalettecolor(int x) {
    ivec2 coord = ivec2(x,0);
    return texelFetch(target_palette, coord, 0).rgb;
}

// https://unlimited3d.wordpress.com/2020/01/08/srgb-color-space-in-opengl/
float Convert_sRGB_FromLinear (float theLinearValue) {
  return theLinearValue <= 0.0031308
       ? theLinearValue * 12.92
       : pow (theLinearValue, 1.0/2.4) * 1.055 - 0.055;
}

float Convert_sRGB_ToLinear (float thesRGBValue) {
  return thesRGBValue <= 0.04045f
       ? thesRGBValue / 12.92f
       : pow ((thesRGBValue + 0.055) / 1.055, 2.4);
}

void fragment() {
    vec3 incolor = texture(TEXTURE, UV).rgb;
    vec2 uv = UV * vec2(640.0, 512.0) / vec2(float(resolution_scale));
        
    // int x = int(floor(mod(uv.x, bayerSize)));
    // int y = int(floor(mod(uv.y, bayerSize)));
    //float ratio = ratio_multiplier * float(bayer[y * int(bayerSize) + x]);
    int x = int(floor(mod(uv.x, matrixSize)));
    int y = int(floor(mod(uv.y, matrixSize)));
    float ratio = ratio_multiplier * float(matrix[y * int(matrixSize) + x]);
    
    // Convert from [0.0, 1.0] range to [0, 255] range
    ivec3 c = ivec3(round(incolor * 255.0));
    ivec3 c_ratio = c + ivec3(int(ratio));
    int closest_palette_idx = getclosestpaletteidx(c_ratio);
    // Note: don't have to convert back to [0.0, 1.0] range because
    // getpalettecolor does by using the [0.0, 1.0] indexed value of the palette
    vec3 closest_color = getpalettecolor(closest_palette_idx);
    
    // ivec3 i_closest_color = ivec3(round(closest_color * 255.0));
    // // Truncate from 8 bits to color_depth bits
    // i_closest_color >>= (8 - color_depth);
    // // Convert back to [0.0, 1.0] range
    // vec3 final_color = vec3(i_closest_color) / float(1 << color_depth);
    
    COLOR.rgb = vec3(
        Convert_sRGB_FromLinear(closest_color.r),
        Convert_sRGB_FromLinear(closest_color.g),
        Convert_sRGB_FromLinear(closest_color.b));
    // Truncate from 8 bits to color_depth bits
    // c_ratio >>= (8 - color_depth);
    // Convert back to [0.0, 1.0] range
    // vec3 final_color = vec3(c_ratio) / float(1 << color_depth);
    // COLOR.rgb = final_color;
}