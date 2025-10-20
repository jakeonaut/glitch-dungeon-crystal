
/*
Shader from Godot Shaders - the free shader library.

This shader is under CC0 license. Feel free to use, improve and 
change this shader according to your needs and consider sharing 
the modified result to godotshaders.com.

Optimised and packed by @c64cosmin
If you do use this please share it with me
Would love to see what you're making with it <3

It's a combination of these two shaders
~godotshaders.com/shader/VHS-and-CRT-monitor-effect
godotshaders.com/shader/crt-shader-with-realistic-blurring/

CRT grille and rolling lines made by @c64cosmin
Vignette and warping effect was made by pend00
Scanlines are from "TimothyLottes" FROM SHADERTOY
Then ported by AHOPNESS (@Ahopness)
https://www.shadertoy.com/view/MsjXzh
*/

shader_type canvas_item;

//uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

uniform vec2 resolution = vec2(320.0, 180.0);

uniform float scan_line_amount :hint_range(0.0, 1.0) = 1.0;
uniform float warp_amount :hint_range(0.0, 5.0) = 0.1;
uniform float grille_amount :hint_range(0.0, 1.0) = 0.1;
uniform float grille_size :hint_range(1.0, 5.0) = 1.0;
uniform float vignette_amount :hint_range(0.0, 2.0) = 0.6;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.4;
uniform float aberation_amount :hint_range(0.0, 1.0) = 0.5;
uniform float scan_line_strength :hint_range(-12.0, -1.0) = -8.0;
uniform float pixel_strength :hint_range(-4.0, 0.0) = -2.0;

float random(vec2 uv){
   return fract(cos(uv.x * 83.4827 + uv.y * 92.2842) * 43758.5453123);
}

vec3 fetch_pixel(vec2 uv, vec2 off, sampler2D screen_texture){
   vec2 pos = floor(uv * resolution + off) / resolution + vec2(0.5) / resolution;

   if(max(abs(pos.x - 0.5), abs(pos.y - 0.5)) > 0.5){
       return vec3(0.0, 0.0, 0.0);
   }

   vec3 screen = texture(screen_texture , pos, -16.0).rgb;
   return screen;
}

// Distance in emulated pixels to nearest texel.
vec2 Dist(vec2 pos){ 
   pos = pos * resolution;
   return - ((pos - floor(pos)) - vec2(0.5));
}

// 1D Gaussian.
float Gaus(float pos, float scale){ return exp2(scale * pos * pos); }

// 3-tap Gaussian filter along horz line.
vec3 Horz3(vec2 pos, float off, sampler2D screen_texture){
   vec3 b = fetch_pixel(pos, vec2(-1.0, off), screen_texture);
   vec3 c = fetch_pixel(pos, vec2( 0.0, off), screen_texture);
   vec3 d = fetch_pixel(pos, vec2( 1.0, off), screen_texture);
   float dst = Dist(pos).x;

   // Convert distance to weight.
   float scale = pixel_strength;
   float wb = Gaus(dst - 1.0, scale);
   float wc = Gaus(dst + 0.0, scale);
   float wd = Gaus(dst + 1.0, scale);

   // Return filtered sample.
   return (b * wb + c * wc + d * wd) / (wb + wc + wd);
}

// Return scanline weight.
float Scan(vec2 pos, float off){
   float dst = Dist(pos).y;

   return Gaus(dst + off, scan_line_strength);
}

// Allow nearest three lines to effect pixel.
vec3 Tri(vec2 pos, sampler2D screen_texture){
   vec3 clr = fetch_pixel(pos, vec2(0.0), screen_texture);
   if(scan_line_amount > 0.0){
       vec3 a = Horz3(pos,-1.0, screen_texture);
       vec3 b = Horz3(pos, 0.0, screen_texture);
       vec3 c = Horz3(pos, 1.0, screen_texture);

       float wa = Scan(pos,-1.0);
       float wb = Scan(pos, 0.0);
       float wc = Scan(pos, 1.0);

       vec3 scanlines = a * wa + b * wb + c * wc;
       clr = mix(clr, scanlines, scan_line_amount);
   }
   return clr;
}

vec2 nesify(vec2 uv) {
    float stepAmtX = 10.0;
    float stepAmtY = 8.0;
    float uvx = 1.0 - floor(uv.x * stepAmtX) / stepAmtX;
    float uvxR = mod(uv.x, 1.0 / stepAmtX);
    float uvy = floor(uv.y * stepAmtY) / stepAmtY;
    float uvyR = mod(uv.y, 1.0 / stepAmtY);
    
    
    return vec2(uvx + uvxR, uvy + uvyR);
}

// Takes in the UV and warps the edges, creating the spherized effect
vec2 warp(vec2 uv){
   uv = nesify(uv);
   vec2 delta = uv - 0.5;
   float delta2 = dot(delta.xy, delta.xy);
   float delta4 = delta2 * delta2;
   float delta_offset = delta4 * warp_amount;

   vec2 warped = uv + delta * delta_offset;
   return (warped - 0.5) / mix(1.0,1.2,warp_amount/5.0) + 0.5;
}

float vignette(vec2 uv){
   uv *= 1.0 - uv.xy;
   float vignette = uv.x * uv.y * 15.0;
   return pow(vignette, vignette_intensity * vignette_amount);
}

float floating_mod(float a, float b){
   return a - b * floor(a/b);
}

vec3 grille(vec2 uv){
   float unit = 3.14;
   float scale = 2.0*unit/grille_size;
   float r = smoothstep(0.5, 0.8, cos(uv.x*scale - unit));
   float g = smoothstep(0.5, 0.8, cos(uv.x*scale + unit));
   float b = smoothstep(0.5, 0.8, cos(uv.x*scale + 3.0*unit));
   return mix(vec3(1.0), vec3(r,g,b), grille_amount);
}

void fragment(){
   vec2 pix = FRAGCOORD.xy;
   vec2 pos = warp(SCREEN_UV);
//   sampler2D screen_texture = SCREEN_TEXTURE;

   vec2 sq_pix = floor(pos * resolution) / resolution + vec2(0.5) / resolution;

   vec3 clr = Tri(pos, SCREEN_TEXTURE);
    float chromatic = aberation_amount;
    vec2 chromatic_x = vec2(chromatic,0.0) / resolution.x;
    vec2 chromatic_y = vec2(0.0, chromatic/2.0) / resolution.y;
    float r = Tri(pos - chromatic_x, SCREEN_TEXTURE).r;
    float g = Tri(pos + chromatic_y, SCREEN_TEXTURE).g;
    float b = Tri(pos + chromatic_x, SCREEN_TEXTURE).b;
    clr = vec3(r,g,b);

   clr *= grille(pix);
   clr *= 1.0 + scan_line_amount * 0.6 + grille_amount * 2.0;
   clr *= vignette(pos);

   COLOR.rgb = clr;
   COLOR.a = 1.0;
}
