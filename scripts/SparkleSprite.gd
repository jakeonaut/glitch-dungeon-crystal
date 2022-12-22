extends "Sprite.gd"

var sparkle_fade_timer = 0
var sparkle_fade_time_limit = 1
var multiplier = 1

func _ready():
    var material = get_material_override().duplicate()
    set_material_override(material)
    if randi() % 2 == 0:
        updateBaseFrame(27, 8)
        max_frames = 3
    multiplier = rand_range(0, 5)
    sparkle_fade_time_limit = rand_range(1, 2)

func _process(delta):
    # super._process(delta) implicit
    delta = delta * global.time_dilation_multiplier
    
    if not visible:
        pass

    var opacity = get_material_override().get_shader_param("opacity")
    global_transform.origin.y -= delta * (multiplier*(1 - opacity) + 1)
    sparkle_fade_timer += (delta * 22)
    if sparkle_fade_timer >= sparkle_fade_time_limit:
        sparkle_fade_timer = 0    
        opacity -= 0.1
        var material = get_material_override().duplicate()
        material.set_shader_param("opacity", opacity)
        set_material_override(material)
        if opacity <= 0:
            queue_free()