extends "../GameMover.gd"

var flipTimer = 0
var flipTimeLimit = 4

onready var dieSound = get_node("Sounds/DieSound")
onready var notDieSound = get_node("Sounds/NotDieSound") if has_node("Sounds/NotDieSound") else null
onready var evolveSound = get_node("Sounds/EvolveSound")
onready var startEvolveSound = get_node("Sounds/StartEvolveSound")
onready var myOtherSprite = get_node("Sprite3D2") if has_node("Sprite3D2") else null
var altGlitchEnemySheet = preload("res://assets/enemy_sheet.png")
var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")
var miniCubeCrystalRes = preload("res://sceneObjects/miniCubeCrystal.tscn")

enum SlimeState {
    IDLE,
    WALK
}
var slime_state = SlimeState.WALK

var slime_state_timer = 0
export var slime_walk_time_limit = 10
var slime_idle_time_limit = 10

var am_i_dying = false
var am_i_in_range_of_player = false
var am_i_really_in_range_of_player = false

export(float) var sprite_offset_y = 0
export var behavior_walking = false
export var behavior_intermittent_walking = false
export var behavior_vertical_walking = false
export var behavior_jumping = false
export var behavior_flip_on_land = false
export var behavior_stop_on_land = false
export var behavior_was_thrown = false
export var behavior_thrower = false
export var behavior_evolve = false
export var behavior_fizzle_out_after_evolve = false
export var behavior_mini_explore = false
export var behavior_directional_bullet = false
export var walk_direction = 1
export var is_particle = false
export var modAmt = 0.5

export var is_static_in_level = true

var is_smacked = false
var smack_timer = 0
var smack_time_limit = 10

var bullet_direction_vector = Vector3(1, 0, 0)
var glitch_switch_timer = 0
var glitch_switch_time_limit = 99

var evolution_timer = 0
export var evolution_time_limit = 15

# Called when the node enters the scene tree for the first time.
func _ready():
    set_process_input(true)
    set_process(true)
    set_physics_process(true)

    if walk_speed == 8:
        walk_speed = 3 # ????????????????????? TODO(jaketrower): Why?
    
    #if behavior_walking:
    #    mySprite.frame_delay = 0.2
    #    mySprite.updateBaseFrame(0, 1)
    if behavior_vertical_walking:
        jump_force = 3
        grav = 0
        terminal_vel = 3
        water_terminal_vel = 3
        true_terminal_vel = 3
    if behavior_jumping and grav == 0:
        grav = 60

    if behavior_evolve:
        mySprite.hframes = mySprite.hframes * 2
        mySprite.vframes = mySprite.vframes * 2
    elif behavior_fizzle_out_after_evolve:
        mySprite.should_soft_fizzle_out = true
    else:
        glitch_switch_time_limit = rand_range(30.0, 50.0)
        mySprite.frame_delay = rand_range(0.3, 0.5)
        
    if behavior_directional_bullet:
        mySprite.texture = altGlitchEnemySheet
        mySprite.set_material_override(null)

    mySprite.material_override = mySprite.material_override.duplicate()

func _process(delta):
    delta = delta * global.time_dilation_multiplier
    
    if is_particle or behavior_directional_bullet:
        if is_particle:
            tryRemoveEnemiesGroup()
        if behavior_jumping:
            on_ground = false
        should_collide_floor = false
        should_collide_ceil = false
        should_collide_horizontally = false
        should_do_fallthrough_area_collision = false
        
    
    if am_i_dying:
        processDeath()
        return
        
    am_i_in_range_of_player = am_i_really_in_range_of_player
    am_i_really_in_range_of_player = false

    if behavior_fizzle_out_after_evolve:
        if not mySprite.visible:
            queue_free()
            return

    # glitchSwitchSprite(delta)

    doHorizontalWalkingBehavior()
    doVerticalWalkingBehavior()
    if behavior_directional_bullet:
        global_transform.origin += bullet_direction_vector * delta
        tryDieToBody()
        bulletTryDieToSolids()
        tryDieToOffscreenCamera()

    if behavior_evolve:
        evolution_timer += (delta*22)
        if evolution_timer > evolution_time_limit/3 and not startEvolveSound.is_playing():
            if not is_particle:
                startEvolveSound.play()
        if evolution_timer > evolution_time_limit:
            evolution_timer = 0
            mySprite.hframes = mySprite.hframes / 2
            mySprite.vframes = mySprite.vframes / 2
            behavior_evolve = false
            if not is_particle:
                evolveSound.play()

            if behavior_fizzle_out_after_evolve:
                glitch_switch_timer = 0
                glitch_switch_time_limit = 99999
                mySprite.should_soft_fizzle_out = true

    if behavior_intermittent_walking:
        slime_state_timer += (delta*22)
        if slime_state == SlimeState.WALK:
            behavior_walking = true
            if slime_state_timer >= slime_walk_time_limit:
                slime_state_timer = 0
                slime_state = SlimeState.IDLE 
        elif slime_state == SlimeState.IDLE:
            behavior_walking = false
            if slime_state_timer >= slime_idle_time_limit:
                slime_state_timer = 0
                slime_state = SlimeState.WALK

    glitchSetSpritesAndCollision()

    if is_smacked:
        smack_timer += (delta * 22)
        if smack_timer >= smack_time_limit:
            unsmack()

func unsmack():
    is_smacked = false
    mySprite.material_override.set_shader_param("time_influence", 3)
    mySprite.material_override.set_shader_param("y_div", 2.3)
    mySprite.material_override.set_shader_param("normal_offset", .02)

    if myOtherSprite:
        myOtherSprite.material_override.set_shader_param("time_influence", 3)
        myOtherSprite.material_override.set_shader_param("y_div", 2.3)
        myOtherSprite.material_override.set_shader_param("normal_offset", .02)
    
func doHorizontalWalkingBehavior():
    if (behavior_intermittent_walking or behavior_walking) and horizontal_collision:
        horizontal_collision = false
        walk_direction = -walk_direction
        if behavior_intermittent_walking:
            behavior_walking = true
            slime_state_timer = 0
            slime_state = SlimeState.WALK
        if myOtherSprite:
            myOtherSprite.flip_h = not myOtherSprite.flip_h
    
func doVerticalWalkingBehavior():
    if behavior_walking and behavior_vertical_walking:
        if on_ground:
            on_ground = false
            walk_direction = 1
            grav = 0
            if myOtherSprite:
                myOtherSprite.flip_v = not myOtherSprite.flip_v
        elif not on_ground and linear_velocity.y == 0:
            walk_direction = -1
            grav = 60
            if myOtherSprite:
                myOtherSprite.flip_v = not myOtherSprite.flip_v
                
func tryDieToBody():
    var areas = smallInteractionArea.get_overlapping_areas()
    for area in areas:
        if area.is_in_group("corporeal_body"):
            summonSmokeClouds(3)
            queue_free()

func bulletTryDieToSolids():
    var x = global_transform.origin.x
    var y = global_transform.origin.y
    
    var coords_a = getLevelTiles().world_to_map(Vector3(x, y, 0))
    var tile_pos_a = getLevelTiles().map_to_world(coords_a.x, coords_a.y, coords_a.z)
    var tile_type_a = getLevelTiles().get_cell_item(coords_a.x, coords_a.y, coords_a.z)

    if isTileSolid(tile_type_a, true, 1, tile_pos_a):
        summonSmokeClouds(3)
        queue_free()

func tryDieToOffscreenCamera():
    var DEATH_MARGIN = 5
    if getGameCamera().rightmost_x > -999:
        if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN or \
        global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN or \
        global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
        global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
            queue_free()
    
# @override
func processPhysics(delta):
    if not am_i_in_range_of_player:
        return
    elif grav == 0 and not behavior_walking and not behavior_intermittent_walking and not behavior_vertical_walking and not behavior_jumping and not behavior_was_thrown:
        return
    else:
        # call GameMover.gd super method
        .processPhysics(delta)

func processDeath():
    if not dieSound.is_playing():
        queue_free()

# func glitchSwitchSprite(delta):
#     glitch_switch_timer += (delta*22)
#     if glitch_switch_timer > glitch_switch_time_limit:
#         mySprite.updateBaseFrame(randi() % 6, randi() % 3)
#         glitch_switch_time_limit = rand_range(30.0, 50.0)
#         glitch_switch_timer = 0

func glitchSetSpritesAndCollision():
    if behavior_jumping or behavior_directional_bullet:
        return
        
    if modAmt > 0:
        mySprite.global_transform.origin.x = stepify(self.global_transform.origin.x, modAmt)
        mySprite.global_transform.origin.y = stepify(self.global_transform.origin.y + sprite_offset_y, modAmt)
        if myOtherSprite:
            myOtherSprite.global_transform.origin.x = stepify(self.global_transform.origin.x, modAmt)
            myOtherSprite.global_transform.origin.y = stepify(self.global_transform.origin.y, modAmt)
        smallInteractionArea.global_transform.origin.x = stepify(self.global_transform.origin.x, modAmt)
        smallInteractionArea.global_transform.origin.y = stepify(self.global_transform.origin.y, modAmt)
    else:
        mySprite.global_transform.origin.y = self.global_transform.origin.y + sprite_offset_y

# @override
func pressingMoveLeft():
    if am_i_dying: return false
    return walk_direction == -1 and not behavior_vertical_walking and (behavior_walking or (behavior_was_thrown and not on_ground))

# @override
func pressingMoveRight():
    if am_i_dying: return false
    return walk_direction == 1 and not behavior_vertical_walking and (behavior_walking or (behavior_was_thrown and not on_ground))

# @override
func justPressedJump():
    if am_i_dying: return false
    return behavior_jumping or (behavior_vertical_walking and walk_direction == 1)
# @override
func pressingJump():
    if am_i_dying: return false
    return behavior_jumping or (behavior_vertical_walking and walk_direction == 1)
    
# @override
func isKindOfOnGround():
    if behavior_vertical_walking:
        return walk_direction == 1
    else:
        return .isKindOfOnGround()
    
# @override
func landed():
    .landed()
    if behavior_flip_on_land:
        walk_direction = -walk_direction
        if myOtherSprite:
            myOtherSprite.flip_h = not myOtherSprite.flip_h
    if behavior_stop_on_land:
        behavior_was_thrown = false
        behavior_jumping = false

func isActive():
    return visible and not behavior_evolve

func activate():
    pass

func passiveActivate(_delta):
    pass

func stopPassiveActivate():
    pass

func tryRemoveEnemiesGroup():
    if smallInteractionArea.is_in_group("enemies"):
        smallInteractionArea.remove_from_group("enemies")

func tryAddEnemiesGroup():
    if not smallInteractionArea.is_in_group("enemies"):
        smallInteractionArea.add_to_group("enemies")

func ouchies_base():
    if am_i_dying:
        return
    if is_static_in_level and not (global.memory.has(level.getShortLevelName()) and global.memory[level.getShortLevelName()].has(self.name)):
        setGlobalMemoryOfHasBeenDefeated()
        var miniCubeCrystal = miniCubeCrystalRes.instance()
        level.add_child(miniCubeCrystal)
        miniCubeCrystal.global_transform.origin = self.global_transform.origin

func ouchies(_broom_origin):
    if is_particle:
        return

    ouchies_base()

    if not am_i_dying:
        am_i_dying = true
        mySprite.restart()
        mySprite.frame_delay = 0.1
        mySprite.max_frames = 4
        mySprite.should_soft_fizzle_out = true
        mySprite.texture = altGlitchEnemySheet
        mySprite.set_material_override(null)
        dieSound.play()
        pauseSelf = true
        tryRemoveEnemiesGroup()

func notOuchies(broom_origin):
    if not is_smacked:
        if notDieSound: notDieSound.play()
        summonSmokeClouds(1, true, true)
        getSmacked(broom_origin)

func playerActivationAreaPassiveActivate():
    am_i_really_in_range_of_player = true

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

func setGlobalMemoryOfHasBeenDefeated():
  if not global.memory.has(level.getShortLevelName()):
    global.memory[level.getShortLevelName()] = {}
  global.memory[level.getShortLevelName()][self.name] = true

export var time_influence = 35
export var y_div = 2.3
export var normal_offset = .15
func getSmacked(_broom_origin):
    mySprite.material_override.set_shader_param("time_influence", time_influence)
    mySprite.material_override.set_shader_param("y_div", y_div)
    mySprite.material_override.set_shader_param("normal_offset", normal_offset)

    if myOtherSprite:
        myOtherSprite.material_override.set_shader_param("time_influence", time_influence)
        myOtherSprite.material_override.set_shader_param("y_div", y_div)
        myOtherSprite.material_override.set_shader_param("normal_offset", normal_offset)
    
    smack_timer = 0
    is_smacked = true
