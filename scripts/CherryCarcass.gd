extends "res://scripts/GameMover.gd"

var shake_power = 0.001
var opacity = 0.5
var shake_color_rate = 0.001
onready var secretAniPlayer = get_node("SecretAnimationPlayer")
onready var mySprite2 = get_node("Sprite3D2")
var is_crumbling = false
onready var fallthroughSolidCollisionShape = get_node("FallthroughSolid/CollisionShape")
var nesting_doll_state = global.NestingDoll.GRANDMA
var returning_recover_time = 0
var returning_recover_time_limit = 3
var returning_to_save_point = 0


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

    if !isActive():
        cooldown_timer += (delta*22)

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

    if is_crumbling:
        mySprite2.visible = false
        opacity -= delta/5
        shake_color_rate += delta/2000
        shake_power += delta/100
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
            # queue_free()
            returning_to_save_point = 1
            returning_recover_time = 0
            pauseSelf = true
            ignorePhysics = true
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("fall")
            pauseAnimation = true
            physics_state = PhysicsState.GLITCH_RECOVERY

    if returning_to_save_point == 1:
        linear_velocity = Vector3(0, 0, 0)
        lv = linear_velocity
        vv = 0
        hv = 0
        fall_timer = 0
        global_transform.origin = moveToward2D(global_transform.origin, last_grounded_pos, delta * 22)
        if compare2D(global_transform.origin, last_grounded_pos):
            global_transform.origin = last_grounded_pos
            returning_to_save_point = 2
    if returning_to_save_point == 2:
        if secretAniPlayer.assigned_animation == "fall":
            secretAniPlayer.play("land")
        returning_recover_time += (delta*11)
        if returning_recover_time >= returning_recover_time_limit:
            returning_recover_time = 0
            ignorePhysics = false
            pauseAnimation = false
            pauseSelf = false
            physics_state = PhysicsState.NORMAL
            returning_to_save_point = 0
            
# @override
func landed():
    .landed()

    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("land")
        
func addJumpSmokeCloud(_flip_flip_h = false):
    pass

func isFallthroughCollisionActive():
    return visible

func fallthroughCollisionActivate(possible_game_mover):
    if possible_game_mover == level.player and level.player.nesting_doll_state == global.NestingDoll.BABY:
        passiveActivate(0, true)
    # mySprite.material_override.set_shader_param("enable_glitch", true)
    # print("set shake power...")
    # shake_power = 0.005
    # mySprite.material_override.set_shader_param("shake_power", shake_power)

var cooldown_timer = 0
var cooldown_time_limit = 5
# @override
func isActive(debug=false):
    return cooldown_timer >= cooldown_time_limit


func passiveActivate(_delta, is_player):
    if is_player:
        if level.player.nesting_doll_state == global.NestingDoll.BABY:
            level.player.shroomAniPlayer.queue("grow")
            level.player.shroomAniPlayer.queue("adjust")
            level.player.getABroom()
            for _i in range(3):
                level.player.spawnASpore(0, -1)
            level.player.nesting_doll_state = global.NestingDoll.GRANDMA
            global.memory["nesting_doll"] = global.NestingDoll.GRANDMA
            queue_free()
