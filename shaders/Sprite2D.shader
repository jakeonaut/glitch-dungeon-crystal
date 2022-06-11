shader_type canvas_item;

uniform sampler2D base_palette : hint_black; // Insert a palette from lospec for instance
uniform sampler2D target_palette : hint_black;
uniform int palette_size = 16;

// https://godotshaders.com/shader/palette-shader-lospec-compatible/
void fragment(){ 
    vec4 color = texture(TEXTURE, UV);
    vec4 new_color = vec4(.0);
    
    for (int i = 0; i < palette_size; i++) {
        vec4 palette_color = texture(base_palette, vec2(1.0 / float(palette_size) * float(i) + 0.5, .0));
        if (distance(palette_color, color) < distance(new_color, color)) {
            new_color = texture(target_palette, vec2(1.0 / float(palette_size) * float(i) + 0.5, .0));
        }
    }
    
    COLOR = new_color;
}