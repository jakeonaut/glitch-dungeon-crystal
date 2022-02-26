extends "GlitchEnemy.gd"

onready var playerActivationAreaCollisionShape = get_node("PlayerActivationArea/CollisionShape")

enum MoleState {
    IDLE,
    PREPARE_JUMP,
    LAND,
    JUMP,
    DIG,
}
var mole_state = MoleState.IDLE
var mole_state_timer = 0
var mole_state_idle_time_limit = 10
var mole_state_dig_time_limit = 10
var mole_state_reset_dig_time_limit = 3
var far_from_home_dist = 5
var has_dug = false

var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")

var fakeLevelTiles = null
func getFakeLevelTiles():
    if fakeLevelTiles == null:
        fakeLevelTiles = level.fakeLevelTiles
    return fakeLevelTiles

var player = null
func getPlayer():
    if player == null:
        player = level.player
    return player

func _ready():
    set_process(true)
    aniPlayer.stop()
    aniPlayer.clear_queue()
    aniPlayer.play("idle")

    mySprite.material_override = mySprite.material_override.duplicate() # make unique
    myOtherSprite.material_override = myOtherSprite.material_override.duplicate() # make unique

func _process(delta):
    # ._process(delta) implicit
    
    delta = delta * global.time_dilation_multiplier
    aniPlayer.playback_speed = global.time_dilation_multiplier
    
    if mole_state == MoleState.IDLE:
        if not aniPlayer.is_playing():
            aniPlayer.play("idle")
            
        mole_state_timer += (delta*22)
        if mole_state_timer >= mole_state_idle_time_limit:
            mole_state_timer = 0
            var i = randi() % 5
            if i == 0:
                pass # stay idle
            elif i == 1 or i == 2:
                walk_direction = 1 if i == 1 else 2
                if isFarFromHome():
                    if global_transform.origin.x > spawn_origin.x:
                        walk_direction = -1
                    else:
                        walk_direction = 1
                myOtherSprite.flip_h = walk_direction == -1
                behavior_jumping = true
                mole_state = MoleState.JUMP
            elif i == 4:
                aniPlayer.stop()
                aniPlayer.clear_queue()
                mole_state = MoleState.DIG
    elif mole_state == MoleState.DIG:
        # falling
        if not on_ground and has_dug:
            mole_state_timer += (delta*22)
            if mole_state_timer >= mole_state_reset_dig_time_limit:
                mole_state = MoleState.IDLE
                
        if on_ground and not aniPlayer.is_playing():
            aniPlayer.play("dig")
            mole_state_timer = 0

        if aniPlayer.assigned_animation == "dig": 
            mole_state_timer += (delta*22)
            if mole_state_timer >= mole_state_dig_time_limit:
                if digTilesBelow(getLevelTiles(), true):
                    digTilesBelow(getFakeLevelTiles(), false)
                    has_dug = true
                mole_state_timer = 0
    elif mole_state == MoleState.PREPARE_JUMP:
        # run away from player
        walk_direction = 1 if getPlayer().global_transform.origin.x < global_transform.origin.x else -1
        myOtherSprite.flip_h = walk_direction == -1
        behavior_jumping = true
        mole_state = MoleState.JUMP
    elif mole_state == MoleState.JUMP:
        behavior_walking = not on_ground
    elif mole_state == MoleState.LAND:
        if not aniPlayer.is_playing():
            mole_state = MoleState.IDLE
            aniPlayer.stop()
            aniPlayer.clear_queue()
            aniPlayer.play("idle")


    if am_i_dying:
        return
        
func isFarFromHome():
    return abs(global_transform.origin.x - spawn_origin.x) > far_from_home_dist

func digTilesBelow(levelTiles, should_summon_clouds):
    var x = global_transform.origin.x
    var y = global_transform.origin.y
    var z = global_transform.origin.z
    var lb = -get_node("CollisionShape").shape.radius
    var rb = -lb
    var bb = -get_node("CollisionShape").shape.height/2
    
    var coords_a = levelTiles.world_to_map(Vector3(x + lb, y + bb - 0.1, z))
    var tile_pos_a = levelTiles.map_to_world(coords_a.x, coords_a.y, coords_a.z)
    var tile_type_a = levelTiles.get_cell_item(coords_a.x, coords_a.y, coords_a.z)

    var coords_b = levelTiles.world_to_map(Vector3(x + rb, y + bb - 0.1, z))
    var tile_pos_b = levelTiles.map_to_world(coords_b.x, coords_b.y, coords_b.z)
    var tile_type_b = levelTiles.get_cell_item(coords_b.x, coords_b.y, coords_b.z)

    var coords_mid = levelTiles.world_to_map(Vector3(x, y + bb - 0.1, z))
    var tile_pos_mid = levelTiles.map_to_world(coords_mid.x, coords_mid.y, coords_mid.z)
    var tile_type_mid = levelTiles.get_cell_item(coords_mid.x, coords_mid.y, coords_mid.z)

    var tiles_dug = 0

    if isTileSolid(tile_type_a, true, 1, tile_pos_a):
        levelTiles.set_cell_item(coords_a.x, coords_a.y, coords_a.z, -1)
        tiles_dug += 1
    if isTileSolid(tile_type_b, true, 1, tile_pos_b):
        levelTiles.set_cell_item(coords_b.x, coords_b.y, coords_b.z, -1)
        tiles_dug += 1
    if isTileSolid(tile_type_mid, true, 1, tile_pos_mid):
        levelTiles.set_cell_item(coords_mid.x, coords_mid.y, coords_mid.z, -1)
        tiles_dug += 1

    if should_summon_clouds and tiles_dug > 0:
        summonSmokeClouds(tiles_dug*2)
                
    return tiles_dug > 0

# @override
func landed():
    .landed()
    behavior_jumping = false
    behavior_walking = false
        
    if mole_state != MoleState.DIG and mole_state != MoleState.IDLE:
        mole_state = MoleState.LAND

# @override, not really until GlitchEnemy gets one
func playerActivationAreaPassiveActivate2():
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
        walk_direction = 1 if getPlayer().global_transform.origin.x < global_transform.origin.x else -1
        myOtherSprite.flip_h = walk_direction == -1

# @override, not really until GlitchEnemy gets one
func playerActivationAreaPassiveActivate3():
    pass
    # if mole_state == MoleState.IDLE or mole_state == MoleState.DIG or mole_state == MoleState.LAND:
    #     mole_state = MoleState.PREPARE_JUMP
    #     behavior_walking = false

# @override
func glitchSetSpritesAndCollision():
    pass

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
