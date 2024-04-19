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
var returning = false
var returning_timer = 0
var returning_time_limit = 5
onready var collisionShape = get_node("Area/CollisionShape")
var smacked_npc = null
var should_die_on_land = false
var have_i_smacked_an_npc = false
var taking_the_player_with_me = false

# Called when the node enters the scene tree for the first time.
func _ready():
    set_process(true)
    set_physics_process(true)
    if is_static_in_level:
        get_node("SecretAnimationPlayer").play("isStaticInLevel")
        grav = 0
 
func _process(delta):
    if get_node("SecretAnimationPlayer").assigned_animation == "die" and not get_node("SecretAnimationPlayer").is_playing():
        queue_free()

    if returning:
        returning_timer += (delta*22)

        pauseSelf = true
        is_active = false
        okay_im_really_done_bye = true
        grav = 0
        behavior_was_thrown = false
        behavior_walking = false
        if walk_direction.x == 1:
            get_node("SecretAnimationPlayer").play("returnAirSpinReverse")
        else:
            get_node("SecretAnimationPlayer").play("returnAirSpin")

        var pos = global_transform.origin
        var playerPos = level.player.global_transform.origin
        global_transform.origin = moveToward2D(pos, playerPos, delta * 22)
        if compare2D(global_transform.origin, playerPos):
            abortSound.activateScript()
            if returning and global.activeInteractor and global.activeInteractor.is_important:
                global.pauseGame = true
        return

    if vv > 0 and not projectile:
        behavior_was_thrown = false
        if should_die_on_land:
            get_node("SecretAnimationPlayer").play("die")
            behavior_walking = false
            behavior_was_thrown = false
            grav = 0
            vv = 0
            linear_velocity.y = 0
            lv.y = 0
    if projectile:
        var has_hit_something = hitStuff(delta)
        if has_hit_something or horizontal_collision or vertical_collision: # ((horizontal_collision or vertical_collision) and level.player.glitch_form != global.GlitchForm.WALK_THROUGH_WALLS):
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
        elif taking_the_player_with_me:
            level.player.on_ground = false
            level.player.global_transform.origin = self.global_transform.origin
            level.player.target_last_grounded_y = self.global_transform.origin.y
            return_timer += (delta*11)
            if return_timer >= returning_time_limit:
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
    if global.activeInteractor and global.activeInteractor.is_important:
        returning = true
        if taking_the_player_with_me:
            level.player.has_broom_flown = true
            level.player.has_landed_since_last_flight = false
            returning = false
            taking_the_player_with_me = false
    tryDieIfTooFarFromPlayer()
    tryDieToOffscreenCamera()
    if not is_static_in_level and was_projectile:
        return_timer += (delta * 22)
        if return_timer >= return_time_limit:
            returning = true
            on_ground = false

    
func tryDieIfTooFarFromPlayer():
    if is_static_in_level or was_projectile or projectile:
        return
        
    var distance = global_transform.origin.distance_to(level.player.global_transform.origin)
    if distance >= 15:
        returning = true

    if level.player.physics_state == level.player.PhysicsState.GLITCH_RECOVERY:
        returning = true

func tryDieToOffscreenCamera():
    var DEATH_MARGIN = 5
    if getGameCamera().rightmost_x > -999:
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
    return visible and on_ground and not behavior_was_thrown and not level.player.is_mushroom_infected

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

# dedupe with SummonedBroom
func hitStuff(_delta):
    if not visible or not projectile or should_die_on_land: return
        
    var my_broom_owner = level.player
    var has_hit_something = false
    var areas = get_node("Area").get_overlapping_areas()
    for area in areas:
        if area.is_in_group("tadpole"):
            continue
        elif area.is_in_group("weak_enemies") and area.has_method("isActive") and area.isActive():
            if not area.get_node("..").am_i_dying:
                area.get_node("..").ouchies(global_transform.origin)
                print("33")
                # my_broom_owner.has_sweeped_glitch = true
                level.summonSmokeClouds(global_transform.origin, 5, true, true)
                # my_broom_owner.getSmacked()
                has_hit_something = true
        elif area.is_in_group("enemies") and area.has_method("isActive") and area.isActive():
            print("...")
            if area.get_node("..").notOuchies(global_transform.origin):
                print("okay...")
                my_broom_owner.getSmacked()
                has_hit_something = true
            print("okay... 2")
                
            # # TODO kill glitches or "free" them like glitch slug...
            
        elif area.is_in_group("corporeal_body"):
            var areaParent = area.get_node("..")
            if canActivate(area) and areaParent != my_broom_owner and areaParent.has_method("isActive") and areaParent.isActive():
                var smackResult = areaParent.getSmacked(global_transform.origin)
                if areaParent.has_method("imAnNpc") and smackResult == null:
                    smacked_npc = weakref(areaParent)
                    have_i_smacked_an_npc = true
                # my_broom_owner.getSmacked()
                if smackResult == null:
                    has_hit_something = true
                print("stop")
        elif area.has_method("isActive") and area.isActive() and area.has_method("InteractActivate"):
            # if you want to check from the area if it is a SummonedBroom or Thrown, just check global.memory["broom"] = false
            if not area.is_in_group("door"):
                area.InteractActivate(false)
                has_hit_something = area.get_parent().has_method("activate")
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
              getLevelTiles().infectSpikes(coords)
              # TODO(jaketrower): also reset the levelTiles array position?
            if getLevelTiles().isTileSoftSand(tile_type):
                getLevelTiles().sweepUpSand(coords)
                my_broom_owner.digSound.play()
                has_hit_something = true
    return has_hit_something

func summonSmokeClouds(num_clouds, play_sound = false, is_glitchy = false):
    level.summonSmokeClouds(global_transform.origin, num_clouds, play_sound, is_glitchy)
