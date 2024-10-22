shader_type spatial;
render_mode blend_mix,depth_draw_alpha_prepass,cull_disabled,diffuse_burley,specular_schlick_ggx,unshaded;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform sampler2D base_palette : hint_albedo;
uniform sampler2D target_palette : hint_albedo;
uniform float opacity = 1.0;

// For outline
uniform vec4 outline_color : hint_color;
uniform float outline_width = 1.0; 

// æŒ¯å‹•ã®å¼·ã•
uniform float shake_power = 0.03;
// æŒ¯å‹•ãƒ–ãƒ­ãƒƒã‚¯ã‚µã‚¤ã‚º
uniform float shake_block_size = 30.5;
// è‰²ã®åˆ†é›¢çŽ‡
uniform float shake_color_rate : hint_range( 0.0, 1.0 ) = 0.01;

uniform bool enable_remove_skin_tone = false;
uniform bool enable_dither = false;
uniform bool enable_no_transparency = false;
uniform bool enable_black_unknown = false;
uniform int palettesize = 16;
uniform int resolution_scale = 1;
uniform int offset = 0;
uniform bool enable_glitch = false;
uniform bool enable_color_glitch = true;
uniform bool disable_glitch_dither = false;
uniform bool enable_palette_cycle = false;
uniform float palette_cycle_speed = 10.0;

vec4 getClosestMatchingFromPalette(ivec3 color) {
    float closest_distance = 9990.0;
    vec4 closest_color = vec4(0, 1.0, 0, 1.0);
    for (int x=0; x<palettesize; x++) {
        vec2 coord = vec2(float(x)/float(palettesize), 0.0);
        vec4 pixelcolor = texture(target_palette, coord);
        ivec3 ipixelcolor = ivec3(round(pixelcolor.rgb * 255.0));
        float dist = distance(vec3(color), vec3(ipixelcolor.rgb));
        if (dist < closest_distance) {
            closest_distance = dist;
            closest_color = pixelcolor;
        }
    }
    return closest_color;
}

int getpaletteidx(vec3 color) {
    for (int x=0; x<palettesize; x++) {
        vec2 coord = vec2(float(x)/float(palettesize),0.0);
        vec3 pixelcolor = texture(base_palette, coord).rgb;
        if (distance(color, pixelcolor) == 0.0) {
            return x;
        }
    }
    return -1;
}

vec3 getpalettecolor(int x) {
    vec2 coord = vec2(float(x)/float(palettesize),0.0);
    return texture(target_palette, coord).rgb;
}

float random(float seed) {
  return fract(543.2543 * sin(dot(vec2(seed, seed), vec2(3525.46, -54.3415))));
}

uniform float normal_offset : hint_range(0, 1, 0.01) = 0.00;
uniform float time_influence : hint_range(0, 50) = 0;
uniform float y_div : hint_range(0, 10, .1) = 0;

void vertex() {
    VERTEX.x += sin(VERTEX.y * y_div + round(TIME * time_influence)) * normal_offset;
    VERTEX.y += sin(VERTEX.x * y_div + round(TIME * time_influence)) * normal_offset;
    VERTEX.z += sin(VERTEX.y * y_div + round(TIME * time_influence)) * normal_offset;
}

const float canvas_width = 2560.0;
const float canvas_height = 2048.0;
const float matrixSize = 4.0;
int getM(int x) {
  if (x == 0) { return 1; }
  if (x == 1) { return 9; }
  if (x == 2) { return 3; }
  if (x == 3) { return 11; }
  
  if (x == 4) { return 13; }
  if (x == 5) { return 5; }
  if (x == 6) { return 15; }
  if (x == 7) { return 7; }
  
  if (x == 8) { return 4; }
  if (x == 9) { return 12; }
  if (x == 10) { return 2; }
  if (x == 11) { return 10; }
  
  if (x == 12) { return 16; }
  if (x == 13) { return 8; }
  if (x == 14) { return 14; }
  if (x == 15) { return 6; }
}
void fragment() {
    
    vec4 incolor = texture(texture_albedo, UV); // COLOR
    float alpha = incolor.a * opacity; 
    if (alpha == 0.0) {
      incolor = vec4(4.0/256.0, 4.0/256.0, 4.0/256.0, 1.0);
    }
    vec2 uv = UV * vec2(canvas_width, canvas_height) / vec2(float(resolution_scale));
    float x = uv.x;
    float y = uv.y;
    int m_x = int(mod(x, matrixSize));
    int m_y = int(mod(y, matrixSize));
    int ratio = getM(m_x + (m_y*int(matrixSize)));

    int index = getpaletteidx(incolor.rgb);
    if (enable_remove_skin_tone && (index == 8 || index == 9)) {
      index = 10;
    }
     
    float fdelta = float(index+offset);
    if (enable_palette_cycle) {
      fdelta = fdelta - (TIME * palette_cycle_speed);
    }
    float mod2 = mod(fdelta,float(palettesize));
    int delta = int(mod2);
     
    vec3 color = getpalettecolor(delta);

    // Convert from [0.0, 1.0] range to [0, 255] range
    ivec3 pixel_color = ivec3(round(color.rgb * 255.0));
    if (alpha == 0.0) {
      pixel_color = ivec3(round(getpalettecolor(4) * 255.0));
    }
    int r = pixel_color.r;
    int g = pixel_color.g;
    int b = pixel_color.b;
    if (enable_dither || (enable_glitch && !disable_glitch_dither)) {
      r = r + ratio;
      g = g + ratio;
      b = b + ratio;
    }
    // Note: don't have to convert back to [0.0, 1.0] range because
    // getClosestMatchingFromPalette uses [0.0, 1.0] value of the palette
    vec4 closest_color = getClosestMatchingFromPalette(ivec3(r, g, b));
    
    if (index > -1) {
        ALBEDO.rgb = closest_color.rgb;
    }
    else if (enable_no_transparency) {
        ALBEDO.rgb = closest_color.rgb;
    }
    else if (enable_black_unknown) {
        ALBEDO.rgb = vec3(0.016, 0.016, 0.016);
    }
    if (enable_no_transparency && alpha == 0.0) {
        alpha = 1.0;
    } else if (closest_color.a == 0.0) {
    alpha = 0.0;
  }
    ALPHA = alpha;

    if (enable_glitch) {
        vec2 fixed_uv = UV;
        fixed_uv.x += (random((trunc(ALBEDO.y * shake_block_size) / shake_block_size) + TIME) - 0.5) * shake_power;
        fixed_uv.y += (random((trunc(ALBEDO.y * shake_block_size) / shake_block_size) + TIME) - 0.5) * shake_power;
    
        vec4 alp = texture(texture_albedo, fixed_uv);

        if (enable_color_glitch) {
            closest_color.r = mix(closest_color.r, texture(texture_albedo, fixed_uv + vec2(shake_color_rate, 0.0)).r, 0.5);
            closest_color.b = mix(closest_color.b, texture(texture_albedo, fixed_uv + vec2(-shake_color_rate, 0.0)).b, 0.5);
        }
        ALBEDO.rgb = closest_color.rgb;
        if (!enable_no_transparency) {
            ALPHA = alp.a * opacity;
        } else {
      ALPHA = opacity;
    }
    }
    
    ALBEDO.rgb = incolor.rgb;
    ALPHA = alpha;
}