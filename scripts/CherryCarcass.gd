extends "res://scripts/GameMover.gd"

var shake_power = 0.001
var opacity = 0.5
var shake_color_rate = 0.001
onready var secretAniPlayer = get_node("SecretAnimationPlayer")
onready var broomSprite = get_node("BroomSprite")
onready var mushroomSprite = get_node("MushroomSprite")
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
func getSmacked(_broom_origin, silently = false):
  if not silently and smackSound: smackSound.play()
  var material = mySprite.material_override
  if material is ShaderMaterial:
    material.set_shader_param("time_influence", 35)
    material.set_shader_param("y_div", 2.3)
    material.set_shader_param("normal_offset", .15)
    mySprite.material_override = material
  smack_timer = 0
  is_smacked = true

onready var mushroomFallthroughSolid = get_node("MushroomFallthroughSolid")
func _process(delta):
    delta = delta * global.time_dilation_multiplier

    broomSprite.global_transform.origin.x = global_transform.origin.x
    broomSprite.flip_h = mySprite.flip_h
    mushroomSprite.global_transform.origin.x = global_transform.origin.x
    mushroomSprite.flip_h = mySprite.flip_h
    mushroomFallthroughSolid.global_transform.origin.x = mushroomFallthroughSolid.global_transform.origin.x
    if mySprite.flip_h:
        broomSprite.global_transform.origin.x -= 1.1
        mushroomSprite.global_transform.origin.x -= 0.2
        mushroomFallthroughSolid.global_transform.origin.x -= 0.2
    else:
        broomSprite.global_transform.origin.x += 1.1
        mushroomSprite.global_transform.origin.x += 0.2
        mushroomFallthroughSolid.global_transform.origin.x += 0.2

    if mushroomSprite.visible and not mushroomFallthroughSolid.is_in_group("fallthrough"):
        mushroomFallthroughSolid.add_to_group("fallthrough")
    elif mushroomFallthroughSolid.is_in_group("fallthrough"):
        mushroomFallthroughSolid.remove_from_group("fallthrough")

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
        broomSprite.visible = false
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
    if on_ground:
        if secretAniPlayer.assigned_animation == "fall":
            secretAniPlayer.play("land")
            
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

onready var bounceSound = get_node("BounceSound")
onready var mushroomBounceAniPlayer = get_node("MushroomBounceAniPlayer")
func fallthroughCollisionActivate(possible_game_mover):
    if mushroomSprite.visible:
        if possible_game_mover != null and possible_game_mover == level.player and not level.player.pressingDown():
            level.player.target_last_grounded_y = level.player.global_transform.origin.y
            var jump_val = 14
            possible_game_mover.magicJump()
            level.player.linear_velocity.y = jump_val
            level.player.lv.y = jump_val
            level.player.vv = jump_val
            # getPlayer().physics_vars.applyHalfGrav = true
            # getPlayer().physics_vars.applyHalfGravTimer = 3
            bounceSound.pitch_scale = rand_range(0.8, 1.5)
            bounceSound.play()
            level.player.target_last_grounded_y = level.player.global_transform.origin.y
            mushroomBounceAniPlayer.stop()
            mushroomBounceAniPlayer.clear_queue()
            mushroomBounceAniPlayer.play("bounce")
            spawnASpore()
    else:
        if possible_game_mover == level.player and level.player.nesting_doll_state == global.NestingDoll.BABY:
            passiveActivate(0, true)
    # mySprite.material_override.set_shader_param("enable_glitch", true)
    # shake_power = 0.005
    # mySprite.material_override.set_shader_param("shake_power", shake_power)

var cooldown_timer = 0
var cooldown_time_limit = 5
# @override
func isActive(_debug=false):
    return cooldown_timer >= cooldown_time_limit


func passiveActivate(_delta, is_player):
    if is_player:
        if level.player.nesting_doll_state == global.NestingDoll.BABY or level.player.nesting_doll_state == global.NestingDoll.MOM:
            level.player.shroomAniPlayer.queue("grow")
            level.player.shroomAniPlayer.queue("adjust")
            level.player.getABroom()
            # for _i in range(3):
            #     level.player.spawnASpore(0, -1)
            level.player.nesting_doll_state = global.NestingDoll.GRANDMA
            global.memory["nesting_doll"] = global.NestingDoll.GRANDMA
            queue_free()

var sporeRes = preload("res://sceneObjects/Environment/Spore.tscn")
func spawnASpore():
    var spore = sporeRes.instance()
    spore.initially_fly_up = true
    level.add_child(spore)
    spore.global_transform.origin = self.global_transform.origin
    spore.original_pos = self.global_transform.origin
    spore.setAsParent(self)
    spore.bubble_speed = -rand_range(2.925, 3.8)
    spore.target_pos.x = self.global_transform.origin.x + rand_range(-4, 4)
    spore.delta_multiplier = 4.0
    spore.global_transform.origin.x += rand_range(-3, 3)
    spore.global_transform.origin.y -= rand_range(0, 1)
    spore.lifespan_time_limit = 15