extends "Sprite.gd"

var target_x = -9999
var target_y = -9999
var fade_out_opacity = false
export var curr_opacity = .5
var opacity_fade_rate = 2
onready var cleanGlitchSound = get_node("CleanGlitchSound") if has_node("CleanGlitchSound") else null
onready var bubbleSound = get_node("BubbleSound") if has_node("BubbleSound") else null
var should_randomize = false

func tryPlaySound():
    if cleanGlitchSound != null:
        cleanGlitchSound.play()
        cleanGlitchSound.pitch_scale = rand_range(0.8, 1.2)
    if bubbleSound != null:
        bubbleSound.play()
        bubbleSound.pitch_scale = rand_range(0.6, 0.9)

func _ready():

    var randint = randi() % 4
    if randint == 1:
        flip_v = true
    if randint == 2:
        flip_h = true
    if randint == 3:
        flip_h = true
        flip_v = true
    var material = get_material_override().duplicate()
    set_material_override(material)
    if should_randomize:
        randomizeFrame()

func _process(delta):
    delta = delta * global.time_dilation_multiplier
    
    # if global.pauseGame: return
    if target_x != -9999:
        global_transform.origin.x = global_transform.origin.x + (target_x - global_transform.origin.x) * delta * 2
    if target_y != -9999:
        global_transform.origin.y = global_transform.origin.y + (target_y - global_transform.origin.y) * delta * 2
    if fade_out_opacity:
        curr_opacity = curr_opacity + (0 - curr_opacity) * delta * opacity_fade_rate
        var material = get_material_override()
        material.set_shader_param("opacity", curr_opacity)
