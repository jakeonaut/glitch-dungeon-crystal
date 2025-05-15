extends "GlitchEnemy.gd"

onready var playerActivationAreaCollisionShape = get_node("PlayerActivationArea/CollisionShape")

onready var digSound = get_node("Sounds/DigSound")
onready var respawnSound = get_node("Sounds/RespawnSound")
onready var thudSound = get_node("Sounds/ThudSound")
enum MoleState {
    IDLE,
    PREPARE_JUMP,
    LAND,
    JUMP,
    DIG,
    DIG_IDLE,
    OVERRIDE_FLY_START,
    OVERRIDE_FLYING,
    RESPAWN,
}
var mole_state = MoleState.IDLE
var mole_state_timer = 0
var mole_state_idle_time_limit = 10
var mole_state_dig_time_limit = 5
var mole_state_reset_dig_time_limit = 8
var far_from_home_dist = 5
var has_dug = false
var has_been_smacked = false
var building_timer = 0
var building_time_limit = 10

export var is_builder = false
export var permanently_alter_tiles = false
export var is_mushroom_infected = false
onready var mushroomSprite = get_node("MushroomSprite")
export var can_hop = false
var initial_grav = 60
var initial_true_terminal_vel = 32
var flight_anchor = null
var do_i_care_about_time_limit = false

var opacity = 1.0

var fakeLevelTiles = null
func getFakeLevelTiles():
    if fakeLevelTiles == null:
        fakeLevelTiles = level.fakeLevelTiles
    return fakeLevelTiles

export var keep_spawning_anyway = false
func _ready():
    if global.demo_mode > 0 or (getMyStaticLevelZoneVar() and not keep_spawning_anyway):
        visible = false
        queue_free()
        return

    set_process(true)
    aniPlayer.stop()
    aniPlayer.clear_queue()
    aniPlayer.play("idle")
    initial_grav = grav
    initial_true_terminal_vel = true_terminal_vel

    mySprite.material_override = mySprite.material_override.duplicate() # make unique
    myOtherSprite.material_override = myOtherSprite.material_override.duplicate() # make unique
    myOtherSprite.global_transform.origin.y = self.global_transform.origin.y + 0.2

func getSmacked(broom_origin = null, silently = false):
    if has_ever_been_smacked or mole_state == MoleState.RESPAWN:
        return
    .getSmacked(broom_origin, silently)
    walk_speed = 0
    grav = 0
    walk_direction.x = -1
    if level.player.mySprite.flip_h:
        walk_direction.x = 1
    linear_velocity.y = 0
    lv.y = 0
    smallInteractionArea.add_to_group("no_pushems")

func shouldIDoCollisions():
    .shouldIDoCollisions()
    should_collide_floor = should_collide_floor or mole_state == MoleState.DIG or mole_state == MoleState.DIG_IDLE

export var is_digging_left = false
var dig_counter = 0
func _process(delta):
    # ._process(delta) implicit

    if is_mushroom_infected:
        myOtherSprite.material_override.set_shader_param("enable_glitch", true)
        mushroomSprite.visible = true

    if is_builder:
        mole_state_dig_time_limit = 3
    
    delta = delta * global.time_dilation_multiplier
    aniPlayer.playback_speed = global.time_dilation_multiplier

    checkForFlyPathOverrides()
    should_collide_horizontally = mole_state != MoleState.OVERRIDE_FLYING
    
    if mole_state == MoleState.IDLE:
        if not aniPlayer.is_playing():
            aniPlayer.play("idle")
            
        if can_hop:
            mole_state_timer += (delta*22)
            if mole_state_timer >= mole_state_idle_time_limit:
                mole_state_timer = 0
                var i = randi() % 4
                if i == 0:
                    pass # stay idle
                elif can_hop and (i == 1 or i == 2):
                    walk_direction.x = 1 if i == 1 else -1
                    # if isFarFromHome():
                    #     if global_transform.origin.x > spawn_origin.x:
                    #         walk_direction.x = -1
                    #     else:
                    #         walk_direction.x = 1
                    myOtherSprite.flip_h = walk_direction.x == -1
                    behavior_jumping = true
                    mole_state = MoleState.JUMP
                elif i == 3:
                    aniPlayer.stop()
                    aniPlayer.clear_queue()
                    mole_state = MoleState.DIG_IDLE

        if has_been_smacked:
            has_been_smacked = false
            startDigging()
    elif mole_state == MoleState.DIG or mole_state == MoleState.DIG_IDLE:
        # falling
        if not on_ground and has_dug and my_up_vector.y == 1:
            mole_state_timer += (delta*22)
            if mole_state_timer >= mole_state_reset_dig_time_limit:
                mole_state = MoleState.IDLE
                grav = initial_grav
                
        if on_ground and not aniPlayer.is_playing():
            if mole_state == MoleState.DIG_IDLE:
                aniPlayer.play("dig", -1, 0.5)
                mole_state_timer = -mole_state_dig_time_limit
            else:
                aniPlayer.play("dig")
                mole_state_timer = 0

        if aniPlayer.assigned_animation == "dig":
            mole_state_timer += (delta*22)
            if mole_state_timer >= mole_state_dig_time_limit:
                if mole_state == MoleState.DIG_IDLE:
                    mole_state = MoleState.IDLE
                else:
                    if is_digging_left or my_up_vector.x == 1:
                        digTiles(getTilesLeftOf(getLevelTiles(), 0.5, is_builder, is_builder), true)
                        if not is_builder: digTiles(getTilesLeftOf(getFakeLevelTiles(), 0.5, is_builder, is_builder), false, true)
                    elif my_up_vector.y == 1:
                        digTiles(getTilesBelow(getLevelTiles(), 0.1, is_builder, is_builder), true)
                        if not is_builder: digTiles(getTilesBelow(getFakeLevelTiles(), 0.1, is_builder, is_builder), false, true)
                    else:
                        if my_up_vector.y == -1:
                            digTiles(getTilesAbove(getLevelTiles(), 0.1, is_builder, is_builder), true)
                            if not is_builder: digTiles(getTilesAbove(getFakeLevelTiles(), 0.1, is_builder, is_builder), false, true)
                        elif my_up_vector.x == -1:
                            digTiles(getTilesRightOf(getLevelTiles(), 0.1, is_builder, is_builder), true)
                            if not is_builder: digTiles(getTilesRightOf(getFakeLevelTiles(), 0.4, is_builder, is_builder), false, true)
                    has_dug = true
                    digSound.play()
                mole_state_timer = 0
            if do_i_care_about_time_limit:
                building_timer += (delta * 11)
                if building_timer >= building_time_limit:
                    grav = 0
                    linear_velocity.y = 0
                    vv = 0
                    aniPlayer.stop()
                    aniPlayer.clear_queue()
                    aniPlayer.play("fly")
                    mole_state = MoleState.OVERRIDE_FLYING
                    should_fade_away = true
    elif mole_state == MoleState.PREPARE_JUMP:
        # run away from player
        walk_direction.x = 1 if getPlayer().global_transform.origin.x < global_transform.origin.x else -1
        myOtherSprite.flip_h = walk_direction.x == -1
        behavior_jumping = true
        mole_state = MoleState.JUMP
    elif mole_state == MoleState.JUMP:
        walk_speed = 5
        behavior_walking = not on_ground
    elif mole_state == MoleState.LAND:
        if not aniPlayer.is_playing():
            mole_state = MoleState.IDLE
            aniPlayer.stop()
            aniPlayer.clear_queue()
            aniPlayer.play("idle")
    elif mole_state == MoleState.OVERRIDE_FLY_START:
        if has_been_smacked or (on_ground and grav != 0):
            grav = 0
            aniPlayer.stop()
            aniPlayer.clear_queue()
            aniPlayer.queue("suddenly_fly")
            if has_been_smacked:
                mole_state = MoleState.OVERRIDE_FLYING
        elif grav == 0 and flight_anchor != null:
            global_transform.origin = global_transform.origin + (flight_anchor.global_transform.origin - global_transform.origin) * (delta*5)
            var step = .5
            if stepify(global_transform.origin.x, step) == stepify(flight_anchor.global_transform.origin.x, step) and \
               stepify(global_transform.origin.y, step) == stepify(flight_anchor.global_transform.origin.y, step):
                mole_state = MoleState.OVERRIDE_FLYING
                myOtherSprite.material_override.set_shader_param("enable_glitch", true)
        elif grav == 0 and should_fade_away:
            mole_state = MoleState.OVERRIDE_FLYING
    elif mole_state == MoleState.OVERRIDE_FLYING:
        tryFadeAway(delta)

        if not aniPlayer.is_playing():
            aniPlayer.play("fly")
            walk_speed = 5

        if has_been_smacked:
            grav = 0
            behavior_walking = true
            myOtherSprite.flip_h = walk_direction.x == -1
            walk_speed = 2
            linear_velocity.y = 0
            lv.y = 0
        elif flight_anchor != null and flight_anchor.frame == 0: # DOWN
            behavior_walking = true
            walk_direction.x = -1
            grav = 50
            true_terminal_vel = 5
        elif flight_anchor != null and flight_anchor.frame == 1: # RIGHT
            myOtherSprite.flip_h = false
            walk_direction.x = 1
            behavior_walking = true
        elif flight_anchor != null and flight_anchor.frame == 2: # LEFT
            myOtherSprite.flip_h = true
            walk_direction.x = -1
            behavior_walking = true
        elif flight_anchor != null and flight_anchor.frame == 3: # UP?
            behavior_walking = true
            walk_direction.x = 1
            grav = -50
            true_terminal_vel = 5
    elif mole_state == MoleState.RESPAWN:
        global_transform.origin = Vector3(spawn_origin.x, spawn_origin.y, spawn_origin.z)
        has_been_smacked = false
        has_ever_been_smacked = false
        behavior_jumping = false
        behavior_walking = false
        grav = 0
        flight_anchor = null
        if not amITouchingSolidTiles(getLevelTiles()):
            if respawn_timer >= respawn_time_limit:
                tryFadeBack(delta)
            else:
                respawn_timer += (delta * 11)

    if am_i_dying:
        return

func amITouchingSolidTiles(currLevelTiles):
  var x = global_transform.origin.x
  var y = global_transform.origin.y
  var z = 0
  
  var coords = currLevelTiles.world_to_map(Vector3(x, y, z))
  for i in [-1, 0, 1]:
    for j in [-1, 0, 1]:
      var tile_type = currLevelTiles.get_cell_item(coords.x + i, coords.y + j, coords.z)
      if currLevelTiles.isTileSoftSand(tile_type):
        return true

  return false

var respawn_timer = 0
var respawn_time_limit = 20
var should_fade_away = false
func tryFadeAway(delta):
    if should_fade_away:
        opacity = opacity + (0.0 - opacity) * (delta * 3)
        myOtherSprite.material_override.set_shader_param("opacity", opacity)
        
        if stepify(opacity, 0.1) == 0:
            if is_builder and not do_i_care_about_time_limit:
                myOtherSprite.material_override.set_shader_param("opacity", 0)
                mole_state = MoleState.RESPAWN
                aniPlayer.stop()
                aniPlayer.clear_queue()
                aniPlayer.play("idle")
                respawn_timer = 0
            else:
                if permanently_alter_tiles:
                    setGlobalMemoryOfHasBeenDefeated()
                queue_free()

func actuallyDieToOffscreenCamera(_delta):
    if permanently_alter_tiles:
        setGlobalMemoryOfHasBeenDefeated()
    queue_free()

func tryFadeBack(delta):
    opacity = opacity + (1.0 - opacity) * (delta * 5)
    myOtherSprite.material_override.set_shader_param("opacity", opacity)
    
    if stepify(opacity, 0.1) == 1.0:
        myOtherSprite.material_override.set_shader_param("opacity", 1.0)
        respawnSound.play()
        mole_state = MoleState.IDLE
        grav = initial_grav

func checkForFlyPathOverrides():
    if mole_state == MoleState.RESPAWN:
        return
    if not (has_been_smacked or (flight_anchor != null and flight_anchor.should_fade_away)):
        return

    var areas = smallInteractionArea.get_overlapping_areas()
    for area in areas:
        if area.is_in_group("flypath") and flight_anchor != area.get_node(".."):
            if not aniPlayer.has_animation("jumpSquatInitial"):
                aniPlayer.rename_animation("jumpSquat", "jumpSquatInitial")
                aniPlayer.add_animation("jumpSquat", aniPlayer.get_animation("jumpStart"))
            behavior_walking = false
            if mole_state != MoleState.OVERRIDE_FLYING:
                grav = 60
            else:
                grav = 0
                linear_velocity.y = 0
                vv = 0
                aniPlayer.stop()
                aniPlayer.clear_queue()
                aniPlayer.play("fly")
            flight_anchor = area.get_node("..")
            if flight_anchor != null:
                should_fade_away = flight_anchor.should_fade_away
            mole_state = MoleState.OVERRIDE_FLY_START
            if permanently_alter_tiles:
                global.setStaticLevelZoneLevelVar(level, self, true)
        
func isFarFromHome():
    return abs(global_transform.origin.x - spawn_origin.x) > far_from_home_dist

# @override
func passiveActivate(delta, is_player):
    .passiveActivate(delta, is_player)
    # myOtherSprite.flip_h = (level.player.global_transform.origin.x <= global_transform.origin.x)

# @override, not really until GlitchEnemy gets one
func playerActivationAreaPassiveActivate2():
    pass

# @override, not really until GlitchEnemy gets one
func playerActivationAreaPassiveActivate3():
    pass
    # if mole_state == MoleState.IDLE or mole_state == MoleState.DIG or mole_state == MoleState.LAND:
    #     mole_state = MoleState.PREPARE_JUMP
    #     behavior_walking = false

# @override
func glitchSetSpritesAndCollision():
    pass

# @override
func unsmack():
    .unsmack()
    has_been_smacked = true
    if not (mole_state == MoleState.OVERRIDE_FLY_START or mole_state == MoleState.OVERRIDE_FLYING or mole_state == MoleState.DIG):
        grav = 60
    

var SOFT_SAND_TOP_TILE = 275
func digTiles(solidTiles, should_summon_clouds, is_fake_tiles = false):
    if not is_builder:
        for i in range(solidTiles.size()):
            var coords = solidTiles[i]
            if coords == null: continue
            var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
            if getLevelTiles().isTileFragileSolid(tile_type):
                getSmacked()
                thudSound.play()
                should_fade_away = flight_anchor != null and flight_anchor.should_fade_away
                mole_state = MoleState.OVERRIDE_FLY_START
                return

    var x_add = 0
    var y_add = 1
    if my_up_vector.y == -1:
        y_add = -1
    elif my_up_vector.x == 1:
        x_add = 1
        y_add = 0
    elif my_up_vector.x == -1:
        x_add = -1
        y_add = 0
    var tiles_dug = 0
    if solidTiles[0] != null:
        var coords_a = solidTiles[0]
        if is_builder:
            levelTiles.addTile(SOFT_SAND_TOP_TILE, Vector3(coords_a.x + x_add, coords_a.y + y_add, coords_a.z), permanently_alter_tiles, false)
        else:
            levelTiles.removeTile(Vector3(coords_a.x, coords_a.y, coords_a.z), permanently_alter_tiles)
        tiles_dug += 1
    if solidTiles[1] != null:
        var coords_mid = solidTiles[1]
        if is_builder:
            levelTiles.addTile(SOFT_SAND_TOP_TILE, Vector3(coords_mid.x + x_add, coords_mid.y + y_add, coords_mid.z), permanently_alter_tiles, false)
        else:
            levelTiles.removeTile(Vector3(coords_mid.x, coords_mid.y, coords_mid.z), permanently_alter_tiles)
        tiles_dug += 1
    if solidTiles[2] != null:
        var coords_b = solidTiles[2]
        if is_builder:
            levelTiles.addTile(SOFT_SAND_TOP_TILE, Vector3(coords_b.x + x_add, coords_b.y + y_add, coords_b.z), permanently_alter_tiles, false)
        else:
            levelTiles.removeTile(Vector3(coords_b.x, coords_b.y, coords_b.z), permanently_alter_tiles)
        tiles_dug += 1

    if is_fake_tiles:
        return

    var TILE_WIDTH = getLevelTiles().cell_size.x
    var TILE_HEIGHT = getLevelTiles().cell_size.y
    if is_builder and level.player.checkSolidTilesOnMe():
        if my_up_vector.y == 1:
            level.player.global_transform.origin.y += TILE_HEIGHT
            level.player.camera_target_y_pos = level.player.global_transform.origin.y
        elif my_up_vector.y == -1:
            level.player.global_transform.origin.y -= TILE_HEIGHT
        elif my_up_vector.x == 1:
            level.player.global_transform.origin.x += TILE_WIDTH
        elif my_up_vector.x == -1:
            level.player.global_transform.origin.x -= TILE_WIDTH

    if should_summon_clouds and tiles_dug > 0:
        level.summonSmokeClouds(global_transform.origin, 2)

    if tiles_dug > 0:
        dig_counter += 1
        if is_builder:
            if my_up_vector.y == 1:
                global_transform.origin.y += TILE_HEIGHT
            elif my_up_vector.y == -1:
                global_transform.origin.y -= TILE_HEIGHT
            elif my_up_vector.x == 1:
                global_transform.origin.x += TILE_WIDTH
            elif my_up_vector.x == -1:
                global_transform.origin.x -= TILE_WIDTH
        else:
            if is_digging_left or my_up_vector.x == 1: global_transform.origin.x -= TILE_WIDTH
            elif my_up_vector.y == 1:
                global_transform.origin.y -= TILE_HEIGHT
            elif my_up_vector.y == -1:
                global_transform.origin.y += TILE_HEIGHT
            elif my_up_vector.x == -1:
                global_transform.origin.x += TILE_WIDTH
    else:
        if not is_builder:
            if is_digging_left or my_up_vector.x == 1: global_transform.origin.x -= TILE_WIDTH
            elif my_up_vector.y == 1:
                on_ground = false
            elif my_up_vector.y == -1:
                global_transform.origin.y += TILE_HEIGHT
            elif my_up_vector.x == -1:
                global_transform.origin.x += TILE_WIDTH
                
    return tiles_dug > 0

# @override
func landed():
    .landed()
    if is_mushroom_infected:
        for _i in range(3):
            spawnASpore()
    behavior_jumping = false
    behavior_walking = false
        
    if mole_state != MoleState.DIG and mole_state != MoleState.IDLE and \
        mole_state != MoleState.OVERRIDE_FLY_START and mole_state != MoleState.OVERRIDE_FLYING \
        and mole_state != MoleState.RESPAWN:
        mole_state = MoleState.LAND

func startDigging():
    dig_counter = 0
    if mole_state == MoleState.IDLE or mole_state == MoleState.LAND:
        if aniPlayer.assigned_animation == "idle":
            aniPlayer.stop()
            aniPlayer.clear_queue()
        mole_state = MoleState.DIG
        has_dug = false
        mole_state_timer = 0
        behavior_walking = false
        behavior_jumping = false

        # run away from player
        walk_direction.x = 1 if getPlayer().global_transform.origin.x < global_transform.origin.x else -1
        myOtherSprite.flip_h = walk_direction.x == -1

var sporeRes = preload("res://sceneObjects/Environment/Spore.tscn")
func spawnASpore():
    var spore = sporeRes.instance()
    spore.initially_fly_up = true
    spore.global_transform.origin = self.global_transform.origin
    spore.original_pos = self.global_transform.origin
    level.add_child(spore)
    spore.bubble_speed = -rand_range(1.925, 2.8)
    spore.target_pos.x = self.global_transform.origin.x + rand_range(-1, 1)
    spore.delta_multiplier = 4.0
    spore.global_transform.origin.x += rand_range(-1, 1)
    spore.global_transform.origin.y += 1.5
    spore.global_transform.origin.y -= rand_range(0, .225)
