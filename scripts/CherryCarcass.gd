extends "res://scripts/GameMover.gd"

var shake_power = 0.001
var opacity = 0.5
var shake_color_rate = 0.001
onready var secretAniPlayer = get_node("SecretAnimationPlayer")


func _ready():
    mySprite.material_override = mySprite.material_override.duplicate()
    should_collide_ceil = false
    should_collide_horizontally = false

var is_smacked = false
var smack_timer = 0
var smack_time_limit = 10
onready var smackSound = get_node("SmackSound") if has_node("SmackSound") else null
func getSmacked(_broom_origin):
  if smackSound: smackSound.play()
  var material = mySprite.material_override
  if material is ShaderMaterial:
    material.set_shader_param("time_influence", 35)
    material.set_shader_param("y_div", 2.3)
    material.set_shader_param("normal_offset", .15)
    mySprite.material_override = material
  smack_timer = 0
  is_smacked = true

func _process(delta):
    delta = delta * global.time_dilation_multiplier

    if is_smacked:
        smack_timer += (delta * 22)
        if smack_timer >= smack_time_limit:
            is_smacked = false
            var material = mySprite.material_override
            if material is ShaderMaterial:
                material.set_shader_param("time_influence", 3)
                # material.set_shader_param("y_div", 2.3)
                material.set_shader_param("normal_offset", .02)
                mySprite.material_override = material
    # if opacity > 0:
    #     opacity -= delta/5
    #     shake_color_rate += delta/2000
    #     shake_power += delta/100
    #     mySprite.material_override.set_shader_param("shake_color_rate", shake_color_rate)
    #     mySprite.material_override.set_shader_param("shake_power", shake_power)
    #     mySprite.material_override.set_shader_param("opacity", opacity)
    #     if opacity <= 0:
    #         queue_free()
            
    var DEATH_MARGIN = 5
    if getGameCamera().rightmost_x > -999:
        if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN or \
        global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN or \
        global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
        global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
            # queue_free()
            grav = 0
            
# @override
func landed():
    .landed()

    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("land")
        
func addJumpSmokeCloud(_flip_flip_h = false):
    pass

func fallthroughCollisionActivate(_possible_game_mover):
    pass
    # mySprite.material_override.set_shader_param("enable_glitch", true)
    # print("set shake power...")
    # shake_power = 0.005
    # mySprite.material_override.set_shader_param("shake_power", shake_power)