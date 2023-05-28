extends "TreasureCollectable.gd"

var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")
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
var returning_time_limit = 25
onready var collisionShape = get_node("Area/CollisionShape")
var has_hit_npc = false
var should_die_on_land = false

# Called when the node enters the scene tree for the first time.
func _ready():
    set_process_input(true)
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
        if returning_timer >= returning_time_limit:
            self.global_transform.origin.x = level.player.global_transform.origin.x
            self.global_transform.origin.y = level.player.global_transform.origin.y
            abortSound.activateScript()
            return

        is_active = false
        okay_im_done = true
        grav = 0
        behavior_was_thrown = false
        behavior_walking = false
        if walk_direction.x == 1:
            get_node("SecretAnimationPlayer").play("returnAirSpinReverse")
        else:
            get_node("SecretAnimationPlayer").play("returnAirSpin")

        var x1 = global_transform.origin.x
        var x2 = level.player.global_transform.origin.x
        global_transform.origin.x = x1 + (x2 - x1) * (delta * 5) 
        var is_x_the_same = false
        if stepify(x1, 1) == stepify(x2, 1):
            global_transform.origin.x = x2
            is_x_the_same = true

        var y1 = global_transform.origin.y
        var y2 = level.player.global_transform.origin.y
        global_transform.origin.y = y1 + (y2 - y1) * (delta * 5) 
        var is_y_the_same = false
        if stepify(y1, 1) == stepify(y2, 1):
            global_transform.origin.y = y2
            is_y_the_same = true

        if is_x_the_same and is_y_the_same:
            abortSound.activateScript()
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
        if horizontal_collision or has_hit_something or vertical_collision or on_ground:
            landSound.play()
            grav = 60
            walk_direction = Vector2(0, 0)
            just_pressed_jump = false
            pressing_jump = false
            returning = true
            behavior_was_thrown = false
            behavior_walking = false
            true_terminal_vel = 16
            get_node("SecretAnimationPlayer").play("isStaticInLevel")
            projectile = false
            was_projectile = true
    tryDieIfTooFarFromPlayer()
    tryDieToOffscreenCamera()
    if not is_static_in_level and was_projectile:
        return_timer += (delta * 22)
        if return_timer >= return_time_limit:
            returning = true
            on_ground = false

    
func tryDieIfTooFarFromPlayer():
    var distance = global_transform.origin.distance_to(level.player.global_transform.origin)
    if distance >= 20:
        returning = true

func tryDieToOffscreenCamera():
    var DEATH_MARGIN = 5
    if getGameCamera().rightmost_x > -999:
        if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN or \
        global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN or \
        global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
        global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
            returning = true

# @override
func pressingMoveLeft():
    return walk_direction.x == -1 and behavior_walking and (projectile or not on_ground)

# @override
func pressingMoveRight():
    return walk_direction.x == 1 and behavior_walking and (projectile or not on_ground)

func isActive():
    return visible and on_ground and not behavior_was_thrown and not level.player.is_mushroom_infected

# @override
func justPressedJump():
    return (behavior_was_thrown and grav > 10 and not walk_direction.y == -1) or (behavior_walking and walk_direction.y == 1)

# @override
func pressingJump():
    return behavior_walking and walk_direction.y == 1

# @override
func isKindOfOnGround():
    return behavior_was_thrown or (behavior_walking and walk_direction.y == 1)

# @override
func alignMySprite():
    pass

func landed():
    get_node("SecretAnimationPlayer").play("land")

func summonSmokeClouds(num_clouds, play_sound = false, is_glitchy = false):
    for _i in range(num_clouds):
        var newSmokeCloud = smokeCloudRes.instance()
        level.add_child(newSmokeCloud)
        newSmokeCloud.global_transform.origin.x = self.global_transform.origin.x + rand_range(-1, 1)
        newSmokeCloud.global_transform.origin.y = self.global_transform.origin.y + rand_range(-1, 1)
        newSmokeCloud.target_y = newSmokeCloud.global_transform.origin.y + rand_range(1, 3)
        if play_sound:
            newSmokeCloud.get_node("CleanGlitchSound").play()
            newSmokeCloud.get_node("CleanGlitchSound").pitch_scale = rand_range(0.8, 1.2)
            play_sound = false
        if is_glitchy:
            var new_material = newSmokeCloud.get_material_override().duplicate()
            new_material.set_shader_param("enable_glitch", "true")
            new_material.set_shader_param("target_palette", global.weird_base_palette)
            newSmokeCloud.set_material_override(new_material.duplicate())

func collectMe():
    get_node("SecretAnimationPlayer").play("GET")
    grav = 0
    getGameCamera().initial_target = level.player.get_node("CameraTarget")
    getGameCamera().actual_target = weakref(getGameCamera().initial_target)

func canActivate(area):
  var areaParent = area.get_node("..")
  return not has_hit_npc or not areaParent.has_method("imAnNpc")

func hitStuff(_delta):
    if not visible or not projectile or should_die_on_land: return
        
    var my_broom_owner = level.player
    var has_hit_something = false
    var areas = get_node("Area").get_overlapping_areas()
    for area in areas:
        if area.is_in_group("weak_enemies") and area.has_method("isActive") and area.isActive():
            if not area.get_node("..").am_i_dying:
                area.get_node("..").ouchies(global_transform.origin)
                # my_broom_owner.has_sweeped_glitch = true
                my_broom_owner.broomSound.play()
                summonSmokeClouds(5, true, true)
                # my_broom_owner.getSmacked()
                has_hit_something = true
        elif area.is_in_group("enemies") and area.has_method("isActive") and area.isActive():
            if global.hasGottenLevelGeode:
                area.get_node("..").ouchies(global_transform.origin)
                my_broom_owner.has_sweeped_glitch = true
                my_broom_owner.broomSound.play()
            else:
                area.get_node("..").notOuchies(global_transform.origin)
            # my_broom_owner.getSmacked()
            has_hit_something = true
            # # TODO kill glitches or "free" them like glitch slug...
            
        elif area.is_in_group("corporeal_body"):
            var areaParent = area.get_node("..")
            if canActivate(area) and areaParent != my_broom_owner and areaParent.has_method("isActive") and areaParent.isActive():
                areaParent.getSmacked(global_transform.origin)
                if areaParent.has_method("imAnNpc"):
                    has_hit_npc = true
                # my_broom_owner.getSmacked()
                has_hit_something = true
        elif not area.is_in_group("door") and area.has_method("isActive") and area.isActive() and area.has_method("InteractActivate"):
            area.InteractActivate()
        elif area.has_method("isActive") and area.isActive() and area.has_method("PassiveInteractActivate"):
            area.PassiveInteractActivate(0, false)
      
        # erase glitch tiles...
        var x = collisionShape.global_transform.origin.x
        var y = collisionShape.global_transform.origin.y
        var tb = y + collisionShape.shape.height/2
        var bb = y - collisionShape.shape.height/2
        var lb = x - collisionShape.shape.radius
        var rb = x + collisionShape.shape.radius
        
        var _has_played_sound = false
        for i in range(int(floor(bb)), int(ceil(tb))):
          for j in range(int(floor(lb)), int(ceil(rb))):
            var coords = getLevelTiles().world_to_map(Vector3(j, i, 0))
            var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
            if isTileSpikes(tile_type) and not getLevelTiles().isTileGlitchSpikes(tile_type):
              my_broom_owner.has_sweeped_glitch = true
              getLevelTiles().infectSpikes(coords)
              # TODO(jaketrower): also reset the levelTiles array position?
    return has_hit_something
