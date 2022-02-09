extends "res://scripts/GameMover.gd"

var shake_power = 0.001
var opacity = 0.5
var shake_color_rate = 0.001
onready var secretAniPlayer = get_node("SecretAnimationPlayer")


func _ready():
    mySprite.material_override = mySprite.material_override.duplicate()
    should_collide_ceil = false
    should_collide_horizontally = false

func _process(delta):
    delta = delta * global.time_dilation_multiplier

    if opacity > 0:
        opacity -= delta/10
        shake_color_rate += delta/2000
        shake_power += delta/1000
        mySprite.material_override.set_shader_param("shake_color_rate", shake_color_rate)
        mySprite.material_override.set_shader_param("shake_power", shake_power)
        mySprite.material_override.set_shader_param("opacity", opacity)
        if opacity <= 0:
            queue_free()
            
    var DEATH_MARGIN = 5
    if getGameCamera().rightmost_x > -999:
        if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN or \
        global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN or \
        global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
        global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
            queue_free()
            
# @override
func landed():
    .landed()

    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("land")
        
func addJumpSmokeCloud(flip_flip_h = false):
    pass

func fallthroughCollisionActivate():
    pass
    # mySprite.material_override.set_shader_param("enable_glitch", true)
    # print("set shake power...")
    # shake_power = 0.005
    # mySprite.material_override.set_shader_param("shake_power", shake_power)