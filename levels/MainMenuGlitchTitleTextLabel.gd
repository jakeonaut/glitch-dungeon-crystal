extends RichTextLabel

var curr_font_idx = 0
var glitched_font_timer = 0
var glitched_font_time_limit = 5

var fontData0 = preload("res://assets/fonts/Sakred.ttf")
var fontSize0 = 64
var fontData1 = preload("res://assets/fonts/PublicPixel.ttf")
var fontSize1 = 28
var fontData2 = preload("res://assets/fonts/PixulBrush.ttf")
var fontSize2 = 38
var fontData3 = preload("res://assets/fonts/VGATypewriterSf.ttf")
var fontSize3 = 64
var fontData4 = preload("res://assets/fonts/debugme.ttf")
var fontSize4 = 108
var fontData5 = preload("res://assets/fonts/Quirk.ttf")
var fontSize5 = 56
var fontData6 = preload("res://assets/fonts/m5x7.ttf")
var fontSize6 = 80
var fontData7 = preload("res://assets/fonts/Ubble.ttf")
var fontSize7 = 56


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    delta = delta * global.time_dilation_multiplier

    glitched_font_timer += (delta * 22)
    if glitched_font_timer >= glitched_font_time_limit:
        glitched_font_timer = 0

        curr_font_idx += 1
        if curr_font_idx > 7:
            curr_font_idx = 0

        var glitched_font = theme.default_font.duplicate()
        glitched_font.resource_local_to_scene = true
        if curr_font_idx == 0:
            glitched_font.set_font_data(fontData0)
            glitched_font.set_size(fontSize0)
        elif curr_font_idx == 1:
            glitched_font.set_font_data(fontData1)
            glitched_font.set_size(fontSize1)
        elif curr_font_idx == 2:
            glitched_font.set_font_data(fontData2)
            glitched_font.set_size(fontSize2)
        elif curr_font_idx == 3:
            glitched_font.set_font_data(fontData3)
            glitched_font.set_size(fontSize3)
        elif curr_font_idx == 4:
            glitched_font.set_font_data(fontData4)
            glitched_font.set_size(fontSize4)
        elif curr_font_idx == 5:
            glitched_font.set_font_data(fontData5)
            glitched_font.set_size(fontSize5)
        elif curr_font_idx == 6:
            glitched_font.set_font_data(fontData6)
            glitched_font.set_size(fontSize6)
        elif curr_font_idx == 7:
            glitched_font.set_font_data(fontData7)
            glitched_font.set_size(fontSize7)
            
        add_font_override("normal_font", glitched_font)
