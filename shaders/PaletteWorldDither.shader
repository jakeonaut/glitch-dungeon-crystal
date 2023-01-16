shader_type canvas_item;

uniform sampler2D target_palette : hint_albedo;
uniform int palettesize = 16;
uniform float resolution_scale = 4;
uniform float canvas_width = 1280.0;
uniform float canvas_height = 1024.0;
uniform float r_mult = 0.0;
uniform float g_mult = 1.0;
uniform float b_mult = -1.0;
// uniform int color_depth : hint_range(1, 8) = 8;

// const int bayer[] = {
//  0,32, 8,40, 2,34,10,42,
// 48,16,56,24,50,18,58,26, 
// 12,44, 4,36,14,46, 6,38, 
// 60,28,52,20,62,30,54,22, 
//  3,35,11,43, 1,33, 9,41, 
// 51,19,59,27,49,17,57,25,
// 15,47, 7,39,13,45, 5,37,
// 63,31,55,23,61,29,53,21
// }; 
// const float bayerSize = 8.0;
// const float bayerDivider = bayerSize * bayerSize;

float myDistance(ivec3 A, ivec3 B) {
    return sqrt(
        pow(float(A.r - B.r), 2.0) +
        pow(float(A.g - B.g), 2.0) +
        pow(float(A.b - B.b), 2.0)
    );
}

vec3 getClosestMatchingFromPalette(ivec3 color) {
    float closest_distance = 9990.0;
    vec3 closest_color = vec3(0, 1.0, 0);
    for (int x=0; x<palettesize; x++) {
        ivec2 coord = ivec2(x,0);
        vec3 pixelcolor = texelFetch(target_palette, coord, 0).rgb;
        ivec3 ipixelcolor = ivec3(round(pixelcolor * 255.0));
        float dist = myDistance(color, ipixelcolor);
        if (dist < closest_distance) {
            closest_distance = dist;
            closest_color = pixelcolor;
        }
    }
    return closest_color;
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

const float matrixSize = 8.0;
const float tile_size = 32.0;
void fragment() {
    int m[] = {
        0,32, 8,40, 2,34,10,42,
        48,16,56,24,50,18,58,26, 
        12,44, 4,36,14,46, 6,38, 
        60,28,52,20,62,30,54,22, 
        3,35,11,43, 1,33, 9,41, 
        51,19,59,27,49,17,57,25,
        15,47, 7,39,13,45, 5,37,
        63,31,55,23,61,29,53,21
    };

    float incolor_r = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE.x*r_mult)).r;
    float incolor_g = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE.x*g_mult)).g;
    float incolor_b = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE.x*b_mult)).b;
    vec3 incolor = vec3(incolor_r, incolor_g, incolor_b);
    vec2 uv = SCREEN_UV * vec2(canvas_width, canvas_height) / vec2(float(resolution_scale));

    float x = uv.x;
    float y = uv.y;
    int tile_x = int(floor(x / tile_size));
    int tile_y = int(floor(y / tile_size));

    ////////////////////////////////////////////////
    // TODO(jaketrower): Select sub-palette is more work...
    ////////////////////////////////////////////////

    int m_x = int(mod(x, matrixSize));
    int m_y = int(mod(y, matrixSize));
    int ratio = m[m_x + (m_y*int(matrixSize))];

    // Convert from [0.0, 1.0] range to [0, 255] range
    ivec3 pixel_color = ivec3(round(incolor * 255.0));
    int r = pixel_color.r + ratio;
    int g = pixel_color.g + ratio;
    int b = pixel_color.b + ratio;
    // Note: don't have to convert back to [0.0, 1.0] range because
    // getClosestMatchingFromPalette uses [0.0, 1.0] value of the palette
    vec3 closest_color = getClosestMatchingFromPalette(ivec3(r, g, b));
    
    COLOR.rgb = vec3(
        Convert_sRGB_FromLinear(closest_color.r),
        Convert_sRGB_FromLinear(closest_color.g),
        Convert_sRGB_FromLinear(closest_color.b)
    );
    COLOR.rgb = incolor;
    // COLOR.rgb = vec3(float(r) / 255.0, float(g) / 255.0, float(b) / 255.0);
}