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
onready var spellbookGlitchSprite = get_node("SpellbookGlitchSprite") if has_node("SpellbookGlitchSprite") else null
var altGlitchEnemySheet = preload("res://assets/enemy_sheet.png")
var bubbleRes = preload("res://sceneObjects/BubbleSpell.tscn")
var miniCubeCrystalRes = preload("res://sceneObjects/miniCubeCrystal.tscn")

enum SlimeState {
    IDLE,
    WALK,
    NULL
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
export var behavior_walk_flip = true
export var behavior_jumping = false
export var behavior_flip_on_land = false
export var behavior_stop_on_land = false
export var behavior_was_thrown = false
export var behavior_thrower = false
export var behavior_evolve = false
export var behavior_fizzle_out_after_evolve = false
export var behavior_phase_through_walls = false
export var behavior_mini_explore = false
export var behavior_directional_bullet = false
export var walk_direction = Vector2(1, 0)
export var is_particle = false

export var is_static_in_level = true

var is_smacked = false
var has_ever_been_smacked = false

var smack_timer = 0
export var smack_time_limit = 10
export var smack_recovery_time_limit = 12

var bullet_direction_vector = Vector3(1, 0, 0)
var glitch_switch_timer = 0
var glitch_switch_time_limit = 99

var evolution_timer = 0
export var evolution_time_limit = 15
export var kill_invis = false
export var kill_immediately = false
export var hp_enemy = 1
var am_i_hurt = false

# Called when the node enters the scene tree for the first time.
func _ready():
    set_process(true)

    if slime_walk_time_limit == null:
        slime_walk_time_limit = 10
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
        
    # if behavior_directional_bullet:
    #     mySprite.texture = altGlitchEnemySheet
    #     mySprite.set_material_override(null)
    # else:
    mySprite.material_override = mySprite.material_override.duplicate()
    if spellbookGlitchSprite:
        spellbookGlitchSprite.material_override = spellbookGlitchSprite.material_override.duplicate()

    yield(TempTimer.idle_frame(self), "timeout")
    if mySprite and glitch_form != global.GlitchForm.NORMAL and not mySprite.is_in_group("sprite"):
        # mySprite.updateBaseFrame(4, 4)
        var target_palette = level.levelTiles.grey_palette
        if glitch_form == global.GlitchForm.FLOOR:
            target_palette = level.levelTiles.red_palette
            spellbookGlitchSprite.frame = 1
        elif glitch_form == global.GlitchForm.LADDER:
            target_palette = level.levelTiles.yellow_palette
            spellbookGlitchSprite.frame = 2
        elif glitch_form == global.GlitchForm.FEATHER:
            target_palette = level.levelTiles.green_palette
            spellbookGlitchSprite.frame = 0
        elif glitch_form == global.GlitchForm.INVISIBLE:
            target_palette = level.levelTiles.black_palette
            spellbookGlitchSprite.frame = 3
        elif glitch_form == global.GlitchForm.WALK_THROUGH_WALLS:
            target_palette = level.levelTiles.white_palette
        if mySprite.material_override != null:
            mySprite.material_override.set_shader_param("target_palette", target_palette)
        if spellbookGlitchSprite != null:
            spellbookGlitchSprite.material_override.set_shader_param("target_palette", target_palette)

func shouldIDoCollisions():
    should_collide_floor = (not on_ground or behavior_walking or behavior_jumping or behavior_was_thrown) and not behavior_phase_through_walls
    should_collide_ceil = (not on_ground or (behavior_walking and walk_direction.y == 1) or behavior_jumping or behavior_was_thrown) and not behavior_phase_through_walls
    should_collide_horizontally = behavior_walking and walk_direction.x != 0 and not behavior_phase_through_walls

onready var glitchSecretAniPlayer = get_node("GlitchSecretAnimationPlayer") if has_node("GlitchSecretAnimationPlayer") else null
func glitchOut():
    if not am_i_dying and glitchSecretAniPlayer:
        glitchSecretAniPlayer.play("glitchOut")
        if is_static_in_level:
            setGlobalMemoryOfHasBeenDefeated()
        am_i_dying = true

func _process(delta):
    delta = delta * global.time_dilation_multiplier

    if glitch_form != global.GlitchForm.NORMAL:
        spellbookGlitchSprite.visible = true

    if global.pauseGame:
        return
    processGlitchFormGlitchiness()
    
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
        
    am_i_in_range_of_player = am_i_really_in_range_of_player
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
        tryDieToBody()
        bulletTryDieToSolids()
        if is_smacked:
            return
        global_transform.origin += bullet_direction_vector * delta

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

func processGlitchFormGlitchiness():
    if glitch_form != global.GlitchForm.NORMAL and mySprite.material_override != null:
        mySprite.flip_h = level.player.global_transform.origin.x < self.global_transform.origin.x
        if level.player.glitch_form == glitch_form and not smallInteractionArea.is_in_group("enemies"):
            mySprite.material_override.set_shader_param("opacity", 1.0)
            mySprite.material_override.set_shader_param("enable_glitch", true)
            mySprite.material_override.set_shader_param("enable_palette_cycle", false)
            mySprite.global_transform.origin.z = 1
            smallInteractionArea.add_to_group("enemies")
            if spellbookGlitchSprite != null:
                spellbookGlitchSprite.global_transform.origin.z = 1.1
                spellbookGlitchSprite.global_transform.origin.y = self.global_transform.origin.y + 1.7
                spellbookGlitchSprite.material_override.set_shader_param("enable_palette_cycle", false)
        elif level.player.glitch_form != glitch_form and smallInteractionArea.is_in_group("enemies"):
            mySprite.material_override.set_shader_param("opacity", 0.05)
            mySprite.material_override.set_shader_param("enable_glitch", false)
            mySprite.material_override.set_shader_param("enable_palette_cycle", true)
            mySprite.global_transform.origin.z = 0
            smallInteractionArea.remove_from_group("enemies")
            if spellbookGlitchSprite != null:
                spellbookGlitchSprite.global_transform.origin.z = 0.1
                # spellbookGlitchSprite.global_transform.origin.y = self.global_transform.origin.y
                spellbookGlitchSprite.material_override.set_shader_param("enable_palette_cycle", true)

func updateFallthroughSolids():
    if fallthroughSolid:
        if fallthroughSolid.is_in_group("fallthrough") and (smallInteractionArea.is_in_group("enemies") or is_particle or behavior_directional_bullet or (glitch_form != global.GlitchForm.NORMAL and level.player.glitch_form != glitch_form)):
            fallthroughSolid.remove_from_group("fallthrough")
        elif not smallInteractionArea.is_in_group("enemies") and not fallthroughSolid.is_in_group("fallthrough"):
            if glitch_form == global.GlitchForm.NORMAL or level.player.glitch_form == glitch_form:
                fallthroughSolid.add_to_group("fallthrough")

var last_palette = global.grey_palette
var should_freeze = false
var is_frozen = false
func unsmack():
    am_i_hurt = false
    mySprite.material_override.set_shader_param("time_influence", 16)
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
    
var should_reset_slime_timer_on_flip = true
func doHorizontalWalkingBehavior():
    if not behavior_walk_flip:
            return
    if behavior_walking and horizontal_collision:
        horizontal_collision = false
        flipWalkingDirection()

func flipWalkingDirection():
    walk_direction.x = -walk_direction.x
    if horizontalTurnSound: horizontalTurnSound.play()
    if behavior_intermittent_walking and should_reset_slime_timer_on_flip and slime_state != SlimeState.NULL:
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
        if behavior_walking:
            DEATH_MARGIN = 0
            if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN:
                global_transform.origin.x -= 0.5
                flipWalkingDirection()
                return
            if global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN:
                global_transform.origin.x += 0.5
                flipWalkingDirection()
                return
        DEATH_MARGIN = 5
        if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN or \
        global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN or \
        global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
        global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
            if is_static_in_level:
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

# @override
func alignMySprite():
    pass 

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
    return not is_smacked and visible and not behavior_evolve and not is_frozen and not am_i_dying

func activate(_is_player):
    if smallInteractionArea.is_in_group("weak_enemies"):
        # this conditional needs to go first cuz almost every weak_enemies is also in enemies, but not vice-versa
        ouchies(global_transform.origin)
        getPlayer().has_sweeped_glitch = true
        getPlayer().glitchTickle()
        level.summonSmokeClouds(global_transform.origin, 5, true, true)
        getPlayer().getSmacked()
    elif smallInteractionArea.is_in_group("enemies"):
        if global.memory["glitched_broom"]:
            ouchies(global_transform.origin)
            getPlayer().getSmacked()
            getPlayer().has_sweeped_glitch = true
            getPlayer().glitchTickle()
        elif notOuchies(global_transform.origin):
            getPlayer().getSmacked()
            getPlayer().has_sweeped_glitch = true
            getPlayer().glitchTickle()
    else:
        getSmacked(global_transform.origin)
        getPlayer().getSmacked()

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

var can_spawn_mini_crystal = true
func ouchies_base(broom_origin):
    if am_i_dying or am_i_freezing: # or am_i_hurt:
        return
    getSmacked(broom_origin)
    # am_i_hurt = true
    if is_static_in_level and not self.getMyStaticLevelZoneVar(true):
        setGlobalMemoryOfHasBeenDefeated()
        if can_spawn_mini_crystal:
            var miniCubeCrystal = miniCubeCrystalRes.instance()
            miniCubeCrystal.is_static_in_level = false
            level.add_child(miniCubeCrystal)
            miniCubeCrystal.global_transform.origin = self.global_transform.origin
            miniCubeCrystal.passiveActivate(0, false)
    if parentSpawner != null and parentSpawner.has_method("myChildDied"):
        parentSpawner.myChildDied()

func ouchies(broom_origin):
    if is_particle:
        return false

    ouchies_base(broom_origin)

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
        print("not ouchies")
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
    if is_static_in_level:
        # global.setStaticLevelZoneLevelVar(level, self, self.global_transform.origin)
        pass

export var time_influence = 35
export var y_div = 2.3
export var normal_offset = .15
var smacked_palette = global.white_palette
func getSmacked(_broom_origin = Vector3(0, 0, 0), silently = false):
    if is_smacked or am_i_dying:
        return false

    if notDieSound and not notDieSound.is_playing() and not silently: notDieSound.play()
    mySprite.material_override.set_shader_param("time_influence", time_influence)
    mySprite.material_override.set_shader_param("y_div", y_div)
    mySprite.material_override.set_shader_param("normal_offset", normal_offset)
    mySprite.material_override.set_shader_param("shake_power", 0.143)
    mySprite.material_override.set_shader_param("shake_block_size", 60)
    mySprite.material_override.set_shader_param("shake_color_rate", 0.219)
    last_palette = mySprite.material_override.get_shader_param("target_palette")
    mySprite.material_override.set_shader_param("target_palette", smacked_palette)

    if myOtherSprite != null and myOtherSprite.material_override != null:
        myOtherSprite.material_override.set_shader_param("time_influence", time_influence)
        myOtherSprite.material_override.set_shader_param("y_div", y_div)
        myOtherSprite.material_override.set_shader_param("normal_offset", normal_offset)
    
    smack_timer = 0
    is_smacked = true
    has_ever_been_smacked = true
    if not silently and mushroomEmbiggensMe and self.scale.x > 1:
        self.scale.x /= 2
        self.scale.y /= 2
        self.scale.z /= 2
    if behavior_directional_bullet:
        level.summonSmokeClouds(global_transform.origin, 3)
        queue_free()
        return false
    return true

var parentSpawner = null
func setAsParent(spawner):
    parentSpawner = spawner

var mushroom_infected = false
var mushroomBabyRefs = []
var mushroomAncestorRef = null
export var mushroomEmbiggensMe = false
func getMushroomInfected(shroom_pos, _ignore_ancestor = false):
    if am_i_dying:
        return

    # if not ignore_ancestor:
    #     if mushroomAncestorRef != null and mushroomAncestorRef.get_ref() != null:
    #         mushroomAncestorRef.get_ref().getMushroomInfected(shroom_pos, true)
    #         return null
    # if mushroom_infected and len(mushroomBabyRefs) > 0:
    #     for mushroomBabyRef in mushroomBabyRefs:
    #         if mushroomBabyRef.get_ref() != null:
    #             mushroomBabyRef.get_ref().getMushroomInfected(shroom_pos, true)
    #     return null

    mushroom_infected = true
    getSmacked(global_transform.origin, true)

    if mushroomEmbiggensMe:
        if self.scale.x < 8:
            self.scale.x *= 2
            self.scale.y *= 2
            self.scale.z *= 2
        return

    var babyTransform = Vector3(0, 0, 0)
    var y_dist = abs(global_transform.origin.y - shroom_pos.y)
    var x_dist = abs(global_transform.origin.x - shroom_pos.x)
    if y_dist < x_dist:
        if global_transform.origin.x > shroom_pos.x:
            babyTransform.x = 2
        else:
            babyTransform.x = -2
    else:
        if global_transform.origin.y > shroom_pos.y:
            babyTransform.y = 2
        else:
            babyTransform.y = -2

    var newMushroomAncestorRef = mushroomAncestorRef if mushroomAncestorRef != null and mushroomAncestorRef.get_ref() != null else weakref(self)
    spawnBabyMushroom(babyTransform, newMushroomAncestorRef)
    

func spawnBabyMushroom(babyTransform, newMushroomAncestorRef):
    var baby = self.duplicate()
    level.add_child(baby)
    baby.global_transform.origin = global_transform.origin + babyTransform
    baby.getSmacked(global_transform.origin, true)
    
    baby.mushroomAncestorRef = newMushroomAncestorRef
    mushroomBabyRefs.push_back(weakref(baby))
    return baby

func reenemize(is_weak = false):
    if not smallInteractionArea.is_in_group("enemies"):
        smallInteractionArea.add_to_group("enemies")
    if is_weak and not smallInteractionArea.is_in_group("weak_enemies"):
        smallInteractionArea.add_to_group("weak_enemies")

func unenemize():
    if smallInteractionArea.is_in_group("enemies"):
        smallInteractionArea.remove_from_group("enemies")
    if smallInteractionArea.is_in_group("weak_enemies"):
        smallInteractionArea.remove_from_group("weak_enemies")
