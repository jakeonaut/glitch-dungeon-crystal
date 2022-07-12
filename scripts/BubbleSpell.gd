extends KinematicBody

onready var mySprite = get_node("Sprite3D")
onready var aniPlayer = get_node("AnimationPlayer")
var original_pos_x = null
var target_pos_x = null
var opacity = 0.5
var target_opacity = 1.0

func _ready():
    mySprite.material_override = mySprite.material_override.duplicate()
    aniPlayer.queue("bubbleGrow")
    aniPlayer.queue("bubble")
    
    original_pos_x = global_transform.origin.x
    randomizeTargetPos()

func _process(delta):
    delta = delta * global.time_dilation_multiplier
    
    global_transform.origin.y += delta*2

    global_transform.origin.x = global_transform.origin.x + (target_pos_x - global_transform.origin.x) * (delta*5)
    if stepify(global_transform.origin.x, 0.1) == target_pos_x:
        randomizeTargetPos()

    opacity = opacity + (target_opacity - opacity) * (delta * 5)
    mySprite.material_override.set_shader_param("opacity", opacity)
    if stepify(opacity, 0.1) == target_opacity:
        if target_opacity == 1.0:
            target_opacity = 0.5
        else:
            target_opacity = 1.0

func randomizeTargetPos():
    target_pos_x = original_pos_x + rand_range(-2, 2)
