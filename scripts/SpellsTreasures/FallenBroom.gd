extends "TreasureCollectable.gd"

onready var broomAbortSound = get_node("NPC TextBox/TextBox/AbortSound")

export var behavior_walking = true
export var behavior_was_thrown = true
export var walk_direction = Vector2(1, 0)
# should be a FSM
var projectile = false
var was_projectile = false
var return_timer = 0
var return_time_limit = 5
var loop_return_time_limit = 10
var returning = false
var returning_timer = 0
var returning_time_limit = 5
onready var collisionShape = get_node("Area/CollisionShape")
onready var mySpriteReal = get_node("Sprite3DReal")
var smacked_npc = null
var should_die_on_land = false
var is_dying = false
var should_return = true
var have_i_smacked_an_npc = false
var taking_the_player_with_me = false

# helper vars for just knowing which direction I was thrown. only relevant if projectile = true
# doesn't actually control physics (see walk_direction, grav, and jump_force for that... weird)
var thrown_direction = Vector2(0, 0)
var can_warp = false

# Called when the node enters the scene tree for the first time.
func _ready():
    set_process(true)
    set_physics_process(false)
    if is_static_in_level:
        get_node("SecretAnimationPlayer").play("isStaticInLevel")
        grav = 0

    should_collide_ceil = true
    should_collide_floor = true
    should_collide_horizontally = true
    is_sprite_flipped = false # need to reset this from NPC UGH

var doing_a_final_hit = false
var can_return_via_input = false
var can_return_via_input_timer = 0
var can_return_via_input_time_limit = 3
func _process(delta):
    if global.pauseGame:
        returning = true
        was_projectile = false
        return

    if get_node("SecretAnimationPlayer").assigned_animation == "die" and not get_node("SecretAnimationPlayer").is_playing():
        queue_free()

    if not level.player.can_broomerang_warp:
        mySpriteReal.material_override.set_shader_param("target_palette", global.black_player_palette)
    else:
        mySpriteReal.material_override.set_shader_param("target_palette", global.player_red_palette)

    if not can_return_via_input:
        can_return_via_input_timer += (delta*11)
        if can_return_via_input_timer >= can_return_via_input_time_limit:
            can_return_via_input_timer = 0
            can_return_via_input = true

    if returning:
        if not should_return:
            die()
            return
        hitStuff(delta)
        returning_timer += (delta*22)

        pauseSelf = true
        is_active = true
        # is_active = false
        okay_im_really_done_bye = true
        grav = 0
        behavior_was_thrown = false
        behavior_walking = false
        if walk_direction.x == 1:
            get_node("SecretAnimationPlayer").play("AirSpinReverse")
        else:
            get_node("SecretAnimationPlayer").play("AirSpin")

        var pos = global_transform.origin
        var playerPos = level.player.global_transform.origin
        global_transform.origin = moveToward2D(pos, playerPos, delta * 22)
        if compare2D(global_transform.origin, playerPos):
            abortSound.activateScript()
            if returning and global.activeInteractor and global.activeInteractor.is_important:
                global.pauseGame = true
    elif projectile:
        on_ground = false
        if Input.is_action_just_pressed("sub_action_button") and global.memory["broomerang"] >= 2 and can_warp:
            if not level.player.can_broomerang_warp:
                level.player.errorSound.play()
            else:
                level.player.global_transform.origin = global_transform.origin
                level.player.global_transform.origin.y -= 1
                level.player.camera_target_y_pos = level.player.global_transform.origin.y
                level.player.gravitySound.play()
                level.player.linear_velocity = self.linear_velocity
                level.player.lv = self.lv
                level.player.vv = self.vv
                level.player.hv = self.hv
                level.player.tryClearFallthroughCollisionSolid(self.global_transform.origin)
                abortSound.activateScript()
                level.player.can_broomerang_warp = false
        if returning and global.activeInteractor and global.activeInteractor.is_important:
            global.pauseGame = true
    can_warp = true

    if vv > 0 and not projectile:
        behavior_was_thrown = false
    if vv < 0 and should_die_on_land:
        die()
    if projectile:
        var has_hit_something = hitStuff(delta)
        if doing_a_final_hit:
            oneMoreHit(delta)
            landSound.play()
            grav = 60
            walk_direction = Vector2(0, 0)
            just_pressed_jump = false
            pressing_jump = false
            returning = true
            return_timer = 0
            behavior_was_thrown = false
            behavior_walking = false
            true_terminal_vel = 16
            get_node("SecretAnimationPlayer").play("isStaticInLevel")
            projectile = false
            was_projectile = true
            if taking_the_player_with_me:
                level.player.has_broom_flown = true
                level.player.has_landed_since_last_flight = false
                taking_the_player_with_me = false
        elif has_hit_something or horizontal_collision or vertical_collision: # ((horizontal_collision or vertical_collision) and level.player.glitch_form != global.GlitchForm.WALK_THROUGH_WALLS):
            doing_a_final_hit = true
            physics_state = PhysicsState.IGNORE_PHYSICS
            global_transform.origin.x += thrown_direction.x * 1
            global_transform.origin.y += thrown_direction.y * 1 
            return
        elif taking_the_player_with_me:
            level.player.on_ground = false
            level.player.global_transform.origin = self.global_transform.origin
            level.player.camera_target_y_pos = self.global_transform.origin.y
            return_timer += (delta*11)
            if return_timer >= return_time_limit:
                return_timer = 0
                returning = false
                var mult = 2
                level.player.linear_velocity = Vector3(linear_velocity.x * mult, linear_velocity.y, 0)
                level.player.lv = Vector3(lv.x * mult, lv.y, 0)
                level.player.vv = vv
                level.player.hv = hv * mult
                level.player.has_broom_flown = true
                level.player.has_landed_since_last_flight = false
                taking_the_player_with_me = false
        else:
            return_timer += (delta*11)
            if return_timer >= loop_return_time_limit:
                return_timer = 0
                returning = true
                on_ground = false
                was_projectile = true
    if global.activeInteractor and global.activeInteractor.is_important:
        returning = true
        if taking_the_player_with_me:
            level.player.has_broom_flown = true
            level.player.has_landed_since_last_flight = false
            returning = false
            taking_the_player_with_me = false
    tryReturnIfTooFarFromPlayer()
    tryReturnToOffscreenCamera()
    if not is_static_in_level and was_projectile:
        return_timer += (delta * 22)
        if return_timer >= return_time_limit:
            returning = true
            on_ground = false

func oneMoreHit(delta):
    # give me one last chance to hit QuestionBlocks and anything else that's clustered up
    # var prev_origin = global_transform.origin
    # get_node("SecretAnimationPlayer").play("finalHit")
    collisionShape.translation = Vector3(0, 0, 0)
    collisionShape.shape.height = 3
    collisionShape.shape.radius = 1.5
    hitStuff(delta)
    # global.memory["fail"].fail = "fail"
    # global_transform.origin = prev_origin

func die():
    if is_dying:
        return
    get_node("SecretAnimationPlayer").play("die")
    behavior_walking = false
    behavior_was_thrown = false
    grav = 0
    vv = 0
    linear_velocity.y = 0
    lv.y = 0
    is_dying = true
    
func tryReturnIfTooFarFromPlayer():
    if is_static_in_level:
        return
        
    var distance = global_transform.origin.distance_to(level.player.global_transform.origin)
    if distance >= 20:
        returning = true

    # if level.player.physics_state == level.player.PhysicsState.GLITCH_RECOVERY:
    #     print("returing 5")
    #     returning = true

func tryReturnToOffscreenCamera():
    var DEATH_MARGIN = 5
    if getGameCamera().rightmost_x > -999:
        if level.pacman_wrapping:
            var buffer = -1
            DEATH_MARGIN = -1
            if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN:
                global_transform.origin.x = getGameCamera().leftmost_x - buffer
            if global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN:
                global_transform.origin.x = getGameCamera().rightmost_x + buffer
            if global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
                global_transform.origin.y = getGameCamera().topmost_y + buffer
            if global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN:
                global_transform.origin.y = getGameCamera().botmost_y - buffer
            return
        DEATH_MARGIN = 5
        if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN or \
        global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN or \
        global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
        global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
            returning = true
            if taking_the_player_with_me:
                level.player.has_broom_flown = true
                level.player.has_landed_since_last_flight = false
                taking_the_player_with_me = false

# @override
func pressingMoveLeft():
    return walk_direction.x == -1 and behavior_walking and (projectile or not on_ground)

# @override
func pressingMoveRight():
    return walk_direction.x == 1 and behavior_walking and (projectile or not on_ground)

func isActive(_debug=false):
    return visible and on_ground and not behavior_was_thrown and not should_die_on_land

# @override
func justPressedJump():
    return not returning and ((behavior_was_thrown and grav > 10 and not walk_direction.y == -1) or (behavior_walking and walk_direction.y == 1))

# @override
func pressingJump():
    return not returning and behavior_walking and walk_direction.y == 1

# @override
func isKindOfOnGround():
    return not returning and (behavior_was_thrown or (behavior_walking and walk_direction.y == 1))

# @override
func alignMySprite():
    pass

func landed():
    if not projectile:
        get_node("SecretAnimationPlayer").play("land")
    if should_die_on_land:
        die()

func collectMe():
    get_node("SecretAnimationPlayer").play("GET")
    grav = 0
    getGameCamera().initial_target = level.player.get_node("CameraTarget")
    getGameCamera().actual_target = weakref(getGameCamera().initial_target)

# dedupe with SummonedBroom
func canActivate(area):
  var areaParent = area.get_node("..")
  # sorry!
  return not areaParent.has_method("imAnNpc") or smacked_npc == null or \
         (not have_i_smacked_an_npc and smacked_npc.get_ref() and \
            (areaParent != smacked_npc.get_ref() or \
              (smacked_npc.get_ref().textBox == global.activeInteractor and \
                !smacked_npc.get_ref().textBox.isWaitingForEndPrompt())))

# dedupe with SummonedBroom, why am i not using global.broomSmackStuff
func hitStuff(_delta):
    if not visible or (not projectile and not was_projectile) or should_die_on_land: return
        
    var my_broom_owner = level.player
    var has_hit_something = false
    var areas = get_node("Area").get_overlapping_areas()
    for area in areas:
        if area.is_in_group("tadpole"):
            continue
        elif area.is_in_group("weak_enemies") and area.has_method("isActive") and area.isActive():
            if not area.get_node("..").am_i_dying:
                if not returning:
                    my_broom_owner.getSmacked()
                    if my_broom_owner.teleport_to == null:
                        my_broom_owner.teleport_to = weakref(area.get_parent())
                        my_broom_owner.teleport_to_origin = area.get_parent().global_transform.origin
                area.get_node("..").ouchies(global_transform.origin)
                my_broom_owner.has_sweeped_glitch = true
                level.summonSmokeClouds(global_transform.origin, 5, true, true)
                # my_broom_owner.should_die_on_land)
                has_hit_something = true
        elif area.is_in_group("enemies") and area.has_method("isActive") and area.isActive():
            if area.get_node("..").notOuchies(global_transform.origin):
                if not returning:
                    my_broom_owner.getSmacked()
                    # my_broom_owner.teleport_to = weakref(area.get_parent())
                    # my_broom_owner.teleport_to_origin = area.get_parent().global_transform.origin
                my_broom_owner.has_sweeped_glitch = true
                has_hit_something = true
                
            # # TODO kill glitches or "free" them like glitch slug...
            
        elif area.is_in_group("corporeal_body"):
            var areaParent = area.get_node("..")
            if canActivate(area) and areaParent != my_broom_owner and areaParent.has_method("isActive") and areaParent.isActive() and areaParent.visible and not returning:
                var smackResult = areaParent.getSmacked(global_transform.origin)
                if areaParent.has_method("imAnNpc") and smackResult == null and not returning:
                    smacked_npc = weakref(areaParent)
                    have_i_smacked_an_npc = true
                if not returning:
                    my_broom_owner.getSmacked()
                    if my_broom_owner.teleport_to == null:
                        my_broom_owner.teleport_to = weakref(area.get_parent())
                        my_broom_owner.teleport_to_origin = area.get_parent().global_transform.origin
                if smackResult != null:
                    has_hit_something = true
        elif area.is_in_group("bug") and is_active:
            var areaParent = area.get_node("..")
            if canActivate(area) and areaParent != my_broom_owner and areaParent.has_method("isActive") and areaParent.isActive():
                var smackResult = areaParent.getSmacked(global_transform.origin)
                if not (area.is_in_group("tadpole") and smackResult == null):
                    if not returning:
                        my_broom_owner.getSmacked()
                        if my_broom_owner.teleport_to == null:
                            my_broom_owner.teleport_to = weakref(area.get_parent())
                            my_broom_owner.teleport_to_origin = area.get_parent().global_transform.origin
                    has_hit_something = true
        elif area.has_method("isActive") and area.isActive() and area.has_method("InteractActivate"):
            # if you want to check from the area if it is a SummonedBroom or Thrown, just check global.memory["broom"] = false
            if not area.is_in_group("door") and not area.is_in_group("true_small_door") and not area.is_in_group("npc"):
                has_hit_something = area.InteractActivate(false)
        elif area.has_method("isActive") and area.isActive() and area.has_method("PassiveInteractActivate"):
            # if you want to check from the area if it is a SummonedBroom or Thrown, just check global.memory["broom"] = false
            area.PassiveInteractActivate(0, false)
      
        # erase glitch tiles...
        var x = collisionShape.global_transform.origin.x
        var y = collisionShape.global_transform.origin.y
        # TODO(jaketrower): This needs to be based on a rotated cylinder
        var tb = y + collisionShape.shape.height/2
        var bb = y - collisionShape.shape.height/2
        var lb = x - collisionShape.shape.radius
        var rb = x + collisionShape.shape.radius
        
        var _has_played_sound = false
        for i in range(int(floor(bb)), int(ceil(tb))):
          for j in range(int(floor(lb)), int(ceil(rb))):
            var coords = getLevelTiles().world_to_map(Vector3(j, i, 0))
            var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
            if getLevelTiles().isTileSpikes(tile_type):
              my_broom_owner.has_sweeped_glitch = true
              my_broom_owner.glitchTickle()
              getLevelTiles().infectSpikes(coords)
            if global.memory["glitched_broom"] and getLevelTiles().isTileFragileSolid(tile_type):
              getLevelTiles().breakFragile(coords)
              # TODO(jaketrower): also reset the levelTiles array position?
            # if getLevelTiles().isTileSoftSand(tile_type):
            #     getLevelTiles().sweepUpSand(coords)
            #     my_broom_owner.digSound.play()
            #     has_hit_something = true
    return has_hit_something

func summonSmokeClouds(num_clouds, play_sound = false, is_glitchy = false):
    level.summonSmokeClouds(global_transform.origin, num_clouds, play_sound, is_glitchy)
