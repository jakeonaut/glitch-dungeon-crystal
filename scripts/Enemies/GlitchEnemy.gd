extends "../GameMover.gd"

var flipTimer = 0
var flipTimeLimit = 4

onready var horizontalTurnSound = get_node("Sounds/HorizontalTurnSound") if has_node("Sounds/HorizontalTurnSound") else null
onready var dieSound = get_node("Sounds/DieSound") if has_node("Sounds/DieSound") else null
onready var notDieSound = get_node("Sounds/NotDieSound") if has_node("Sounds/NotDieSound") else null
onready var evolveSound = get_node("Sounds/EvolveSound") if has_node("Sounds/EvolveSound") else null
onready var startEvolveSound = get_node("Sounds/StartEvolveSound") if has_node("Sounds/StartEvolveSound") else null
onready var myOtherSprite = get_node("Sprite3D2") if has_node("Sprite3D2") else null
onready var fallthroughSolid = get_node("FallthroughSolid") if has_node("FallthroughSolid") else null
var altGlitchEnemySheet = preload("res://assets/enemy_sheet.png")
var bubbleRes = preload("res://sceneObjects/BubbleSpell.tscn")
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
var am_i_freezing = false
var am_i_in_range_of_player = false
var am_i_really_in_range_of_player = false
export var only_activate_in_range = true

export(float) var sprite_offset_y = 0.0
export var behavior_walking = false
export var behavior_intermittent_walking = false
export var behavior_jumping = false
export var behavior_flip_on_land = false
export var behavior_stop_on_land = false
export var behavior_was_thrown = false
export var behavior_thrower = false
export var behavior_evolve = false
export var behavior_fizzle_out_after_evolve = false
export var behavior_mini_explore = false
export var behavior_directional_bullet = false
export var walk_direction = Vector2(1, 0)
export var is_particle = false

export var is_static_in_level = true

var is_smacked = false
var has_ever_been_smacked = false

var smack_timer = 0
export var smack_time_limit = 5
export var smack_recovery_time_limit = 6

var bullet_direction_vector = Vector3(1, 0, 0)
var glitch_switch_timer = 0
var glitch_switch_time_limit = 99

var evolution_timer = 0
export var evolution_time_limit = 15
export var kill_invis = false
export var kill_immediately = false

# Called when the node enters the scene tree for the first time.
func _ready():
    set_process(true)
    if is_static_in_level and self.getMyStaticLevelZoneVar():
        set_process(false)
        yield(TempTimer.idle_frame(self), "timeout")
        yield(TempTimer.idle_frame(self), "timeout")
        var miniCubeCrystal = miniCubeCrystalRes.instance()
        level.add_child(miniCubeCrystal)
        miniCubeCrystal.global_transform.origin = global.normalizeMemoryPosition(self.getMyStaticLevelZoneVar())
        miniCubeCrystal.addPlusSprite()
        miniCubeCrystal.queue_free()
        queue_free()
        return

    

    if walk_speed == 8:
        walk_speed = 3 # ????????????????????? TODO(jaketrower): Why?
    
    #if behavior_walking:
    #    mySprite.frame_delay = 0.2
    #    mySprite.updateBaseFrame(0, 1)
    if walk_direction == null:
        walk_direction = Vector2(1, 0) # ????????????????????? TODO(jaketrower): Why?

    if walk_direction.y != 0:
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

func shouldIDoCollisions():
    should_collide_floor = not on_ground or behavior_walking or behavior_jumping or behavior_was_thrown
    should_collide_ceil = not on_ground or (behavior_walking and walk_direction.y == 1) or behavior_jumping or behavior_was_thrown
    should_collide_horizontally = behavior_walking and walk_direction.x != 0

onready var glitchSecretAniPlayer = get_node("GlitchSecretAnimationPlayer") if has_node("GlitchSecretAnimationPlayer") else null
func glitchOut():
    if not am_i_dying and glitchSecretAniPlayer:
        glitchSecretAniPlayer.play("glitchOut")
        setGlobalMemoryOfHasBeenDefeated()
        am_i_dying = true

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
        is_a_physics_particle = true
    else:
        shouldIDoCollisions()
    updateFallthroughSolids()
        
    
    if am_i_dying:
        processDeath()
        return
        
    am_i_in_range_of_player = true # am_i_really_in_range_of_player
    am_i_really_in_range_of_player = false

    if behavior_fizzle_out_after_evolve:
        if not mySprite.visible:
            queue_free()
            return

    # glitchSwitchSprite(delta)

    doHorizontalWalkingBehavior()
    doVerticalWalkingBehavior()
    tryDieToOffscreenCamera()
    if behavior_directional_bullet:
        global_transform.origin += bullet_direction_vector * delta
        tryDieToBody()
        bulletTryDieToSolids()

    if behavior_evolve:
        evolution_timer += (delta*22)
        if startEvolveSound != null and evolution_timer > evolution_time_limit/3 and not startEvolveSound.is_playing():
            if not is_particle:
                startEvolveSound.play()
        if evolution_timer > evolution_time_limit:
            evolution_timer = 0
            mySprite.hframes = mySprite.hframes / 2
            mySprite.vframes = mySprite.vframes / 2
            behavior_evolve = false
            if not is_particle and evolveSound != null:
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
        if smack_timer >= smack_recovery_time_limit:
            is_smacked = false

func updateFallthroughSolids():
    if fallthroughSolid:
        if (smallInteractionArea.is_in_group("enemies") and fallthroughSolid.is_in_group("fallthrough")) or is_particle or behavior_directional_bullet:
            fallthroughSolid.remove_from_group("fallthrough")
        elif not smallInteractionArea.is_in_group("enemies") and not fallthroughSolid.is_in_group("fallthrough"):
            fallthroughSolid.add_to_group("fallthrough")

var last_palette = global.grey_palette
var should_freeze = false
var is_frozen = false
func unsmack():
    mySprite.material_override.set_shader_param("time_influence", 3)
    mySprite.material_override.set_shader_param("y_div", 2.3)
    mySprite.material_override.set_shader_param("normal_offset", .02)
    mySprite.material_override.set_shader_param("shake_power", 0.03)
    mySprite.material_override.set_shader_param("shake_block_size", 30.5)
    mySprite.material_override.set_shader_param("shake_color_rate", 0.01)
    if should_freeze:
        mySprite.material_override.set_shader_param("shake_power", 0.00)
        mySprite.material_override.set_shader_param("target_palette", global.kirokaze_palette)
        mySprite.material_override.set_shader_param("enable_glitch", false)
        mySprite.translation.z = 0
        mySprite.should_animate = false
        mySprite.restart()
        grav = 20
        on_ground = false
        is_frozen = true
    else:
        mySprite.material_override.set_shader_param("shake_power", 0.03)
        mySprite.material_override.set_shader_param("target_palette", last_palette)

    if myOtherSprite:
        myOtherSprite.material_override.set_shader_param("time_influence", 3)
        myOtherSprite.material_override.set_shader_param("y_div", 2.3)
        myOtherSprite.material_override.set_shader_param("normal_offset", .02)
    
func doHorizontalWalkingBehavior():
    if (behavior_intermittent_walking or behavior_walking) and horizontal_collision:
        horizontal_collision = false
        walk_direction.x = -walk_direction.x
        if horizontalTurnSound: horizontalTurnSound.play()
        if behavior_intermittent_walking:
            behavior_walking = true
            slime_state_timer = 0
            slime_state = SlimeState.WALK
        if myOtherSprite:
            myOtherSprite.flip_h = not myOtherSprite.flip_h
    
func doVerticalWalkingBehavior():
    if behavior_walking and walk_direction.y != 0:
        if on_ground:
            on_ground = false
            walk_direction.y = 1
            grav = 0
            if myOtherSprite:
                myOtherSprite.flip_v = not myOtherSprite.flip_v
        elif not on_ground and linear_velocity.y == 0:
            walk_direction.y = -1
            grav = 60
            if myOtherSprite:
                myOtherSprite.flip_v = not myOtherSprite.flip_v
                
func tryDieToBody():
    var areas = smallInteractionArea.get_overlapping_areas()
    for area in areas:
        if area.is_in_group("corporeal_body"):
            level.summonSmokeClouds(global_transform.origin, 3)
            queue_free()

func bulletTryDieToSolids():
    var x = global_transform.origin.x
    var y = global_transform.origin.y
    
    var coords_a = getLevelTiles().world_to_map(Vector3(x, y, 0))
    var tile_pos_a = getLevelTiles().map_to_world(coords_a.x, coords_a.y, coords_a.z)
    var tile_type_a = getLevelTiles().get_cell_item(coords_a.x, coords_a.y, coords_a.z)

    if isTileSolid(tile_type_a, true, 1, tile_pos_a):
        level.summonSmokeClouds(global_transform.origin, 3)
        queue_free()

func tryDieToOffscreenCamera():
    var DEATH_MARGIN = 5
    if getGameCamera().rightmost_x > -999:
        if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN or \
        global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN or \
        global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
        global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
            setGlobalMemoryOfHasBeenDefeated()
            queue_free()
    
var override_am_i_in_range_of_player = false
# @override
func processPhysics(delta):
    if not visible:
        return
    elif only_activate_in_range and not am_i_in_range_of_player and not override_am_i_in_range_of_player:
        return
    elif grav == 0 and not behavior_walking and not behavior_intermittent_walking and not behavior_jumping and not behavior_was_thrown:
        return
    else:
        # call GameMover.gd super method
        .processPhysics(delta)

func processDeath():
    if dieSound == null or not dieSound.is_playing():
        queue_free()

# func glitchSwitchSprite(delta):
#     glitch_switch_timer += (delta*22)
#     if glitch_switch_timer > glitch_switch_time_limit:
#         mySprite.updateBaseFrame(randi() % 6, randi() % 3)
#         glitch_switch_time_limit = rand_range(30.0, 50.0)
#         glitch_switch_timer = 0

func glitchSetSpritesAndCollision():
    mySprite.global_transform.origin.y = self.global_transform.origin.y + sprite_offset_y

# @override
func pressingMoveLeft():
    if am_i_dying or am_i_freezing: return false
    return walk_direction.x == -1 and (behavior_walking or (behavior_was_thrown and not on_ground))

# @override
func pressingMoveRight():
    if am_i_dying or am_i_freezing: return false
    return walk_direction.x == 1 and (behavior_walking or (behavior_was_thrown and not on_ground))

# @override
func justPressedJump():
    if am_i_dying or am_i_freezing: return false
    return behavior_jumping or (behavior_walking and walk_direction.y == 1)

# @override
func pressingJump():
    if am_i_dying or am_i_freezing: return false
    return behavior_jumping or (behavior_walking and walk_direction.y == 1)

# @override
func isKindOfOnGround():
    if behavior_walking and walk_direction.y != 0:
        return walk_direction.y == 1
    else:
        return .isKindOfOnGround()
    
# @override
func landed():
    .landed()
    if behavior_flip_on_land:
        walk_direction.x = -walk_direction.x
        if myOtherSprite:
            myOtherSprite.flip_h = not myOtherSprite.flip_h
    if behavior_stop_on_land:
        behavior_was_thrown = false
        behavior_jumping = false

func isActive(_debug=false):
    return visible and not behavior_evolve and not is_frozen and not am_i_dying

func activate(_is_player):
    pass
    # getSmacked(self.global_transform.origin)
    # getPlayer().getSmacked()

func passiveActivate(_delta, _is_player):
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
    if am_i_dying or am_i_freezing:
        return
    if is_static_in_level and not self.getMyStaticLevelZoneVar(true):
        setGlobalMemoryOfHasBeenDefeated()
        var miniCubeCrystal = miniCubeCrystalRes.instance()
        miniCubeCrystal.is_static_in_level = false
        level.add_child(miniCubeCrystal)
        miniCubeCrystal.global_transform.origin = self.global_transform.origin
        miniCubeCrystal.passiveActivate(0, false)
    if parentSpawner != null and parentSpawner.has_method("myChildDied"):
        parentSpawner.myChildDied()

func ouchies(_broom_origin):
    if is_particle:
        return false

    ouchies_base()

    if not am_i_dying and not am_i_freezing:
        am_i_freezing = true
        mySprite.frame_delay = 0.1
        mySprite.max_frames = 1
        mySprite.restart()
        # mySprite.texture = altGlitchEnemySheet
        if dieSound != null: dieSound.play()
        pauseSelf = true
        tryRemoveEnemiesGroup()
        # glitchSecretAniPlayer.play("freeze")
        should_freeze = true
        return true
    return false

# is this cheating?
var player = null
func getPlayer():
  if level == null:
    level = get_tree().get_root().get_node("Game/Viewport/level")
  if player == null:
    player = level.player
  return player

func notOuchies(broom_origin):
    if not is_smacked:
        level.summonSmokeClouds(global_transform.origin, 1, true, true)
        return getSmacked(broom_origin)
    return false

func playerActivationAreaPassiveActivate():
    am_i_really_in_range_of_player = true

# TODO(jaketrower): Honestly just move these to GameMover...
func spawnABubble(is_horizontal):
    var bubble = bubbleRes.instance()
    level.add_child(bubble)
    bubble.is_horizontal = is_horizontal
    bubble.global_transform.origin = self.global_transform.origin
    if is_horizontal:
        bubble.my_diff_max = 0.5
        if mySprite.flip_h:
            bubble.global_transform.origin.x -= 1
            bubble.horizontal_direction = -1
        else:
            bubble.global_transform.origin.x += 1
            bubble.horizontal_direction = 1
        bubble.my_original_pos = self.global_transform.origin.y
        bubble.my_target_pos = self.global_transform.origin.y + rand_range(-1, 1)
    else:
        bubble.my_original_pos = self.global_transform.origin.x
        bubble.my_target_pos = self.global_transform.origin.x + rand_range(-1, 1)
        bubble.global_transform.origin.y += 1
    bubble.setAsParent(self)

func setGlobalMemoryOfHasBeenDefeated():
    # global.setStaticLevelZoneLevelVar(level, self.name, self.global_transform.origin)
    pass

export var time_influence = 35
export var y_div = 2.3
export var normal_offset = .15
var smacked_palette = global.white_palette
func getSmacked(_broom_origin):
    if is_smacked:
        return false

    if notDieSound and not notDieSound.is_playing(): notDieSound.play()
    mySprite.material_override.set_shader_param("time_influence", time_influence)
    mySprite.material_override.set_shader_param("y_div", y_div)
    mySprite.material_override.set_shader_param("normal_offset", normal_offset)
    mySprite.material_override.set_shader_param("shake_power", 0.143)
    mySprite.material_override.set_shader_param("shake_block_size", 60)
    mySprite.material_override.set_shader_param("shake_color_rate", 0.219)
    last_palette = mySprite.material_override.get_shader_param("target_palette")
    mySprite.material_override.set_shader_param("target_palette", smacked_palette)

    if myOtherSprite:
        myOtherSprite.material_override.set_shader_param("time_influence", time_influence)
        myOtherSprite.material_override.set_shader_param("y_div", y_div)
        myOtherSprite.material_override.set_shader_param("normal_offset", normal_offset)
    
    smack_timer = 0
    is_smacked = true
    has_ever_been_smacked = true
    return true

var parentSpawner = null
func setAsParent(spawner):
    parentSpawner = spawner
