extends "../GlitchEnemy.gd"

onready var secretAniPlayer = get_node("SecretAnimationPlayer")
onready var secretBounceAniPlayer = get_node("SecretBounceAnimationPlayer")
onready var noseSprite = get_node("SpriteContainer/InnerSpriteContainer/NoseSprite")
onready var spriteContainer = get_node("SpriteContainer")
onready var thudSound = get_node("Sounds/ThudSound")
onready var digSound = get_node("Sounds/DigSound")
onready var cubeCrystal = weakref(get_node("CubeCrystal"))

var num_hits = 0
var MAX_NUM_HITS = 3
var num_granny_hits = 3

var dreidel_timer = 0
var dreidel_time_limit = 60
var dreidel_charge_time_limit = 14
var dizzy_timer = 0
var dizzy_time_limit = 120
var smokeCloudTimer = 0
var idle_stomp_timer = 0
var idle_stomp_time_limit = 10
var waddle_timer = 0
var waddle_time_limit = 15

enum BossPhase {
    ASLEEP,
    WAKEUP,
    IDLE,
    IDLE_STOMP,
    WADDLE,
    JUMP_SQUAT,
    JUMP,
    START_DRILL_ATTACK,
    DRILL_FALL,
    DRILL_DREIDEL_SPIN,
    DIZZY,
    SPAWN_BIG_ROCK,
    HURT,
    DEFEATED,
    NULL,
}
var behavior_should_drill = false
var behavior_should_fall_rocks = false
var boss_phase = BossPhase.ASLEEP
var asleep_unearth_counter = 0
onready var spawnSound = get_node("Sounds/SpawnSound")
var weakEyeRes = preload("res://sceneObjects/Enemies/WeakEye.tscn")
var fallingRockRes = preload("res://sceneObjects/Enemies/FallingRock.tscn")
var wormRes = preload("res://sceneObjects/Enemies/Worm.tscn")
var ghostEnemyRes = preload("res://sceneObjects/Enemies/GhostEnemy.tscn")
var fallingRockTimer = 0
var fallingRockTimeLimit = 10
var big_rock_counter = 0
var big_rock_count_max = 2
var myBigRock = null

func _ready():
    num_granny_hits += global.getNumGrannyHearts()
    
    if global.memory["claydolShortcut"] == 0:
        global.memory["claydolShortcut"] = 1
    set_process(true)
    # sprite_offset_y = 7.5

# be careful cuz both the HurtPlayerArea and the InteractArea will both rely on this one function...
func isActive(debug = false):
    return .isActive(debug) and boss_phase != BossPhase.DIZZY

func getMyVariable():
    return global.memory["dogu_matryoshka_boss"]

var cautionWarningRes = preload("res://sceneObjects/Enemies/Boss/CautionWarning.tscn")
var cautionWarning = null
var rememberedCautionWarningPos = null
func enableAndPositionCautionWarning():
    if cautionWarning == null:
        cautionWarning = weakref(cautionWarningRes.instance())
        level.add_child(cautionWarning.get_ref())
    
    var unprojectedPosition = getGameCamera().unproject_position(Vector3(8, self.global_transform.origin.y + 0, 0))
    if boss_phase == BossPhase.START_DRILL_ATTACK or boss_phase == BossPhase.DRILL_DREIDEL_SPIN:
        if rememberedCautionWarningPos == null:
            rememberedCautionWarningPos = unprojectedPosition
        else:
            unprojectedPosition = rememberedCautionWarningPos
        cautionWarning.get_ref().scale = Vector3(1.5, 1.5, 1)
    elif boss_phase == BossPhase.IDLE_STOMP:
        unprojectedPosition = getGameCamera().unproject_position(self.global_transform.origin)
        cautionWarning.get_ref().scale = Vector3(1, 1, 1)
        
    cautionWarning.get_ref().global_transform.origin = getGameCamera().project_position(unprojectedPosition, 0)
    cautionWarning.get_ref().global_transform.origin.z = 10

func tryToDeleteCautionWarning():
    if cautionWarning != null and cautionWarning.get_ref() != null:
        cautionWarning.get_ref().aniPlayer.stop()
        cautionWarning.get_ref().aniPlayer.clear_queue()
        cautionWarning.get_ref().aniPlayer.play("byebye")
        cautionWarning = null
        rememberedCautionWarningPos = null

func _process(delta):
    if not visible or boss_phase == BossPhase.NULL: return

    delta_time_dilation = global.SLOW_BOSS_MULTIPLIER if global.memory["secret_bauble"] and global.memory["secret_bauble_enabled"] else 1.0
    if boss_phase != BossPhase.WAKEUP and boss_phase != BossPhase.HURT and boss_phase != BossPhase.DEFEATED:
        delta = delta * global.time_dilation_multiplier * delta_time_dilation
        secretAniPlayer.playback_speed = global.time_dilation_multiplier * delta_time_dilation
    else:
        secretAniPlayer.playback_speed = 1
    
    noseSprite.flip_h = mySprite.flip_h
    # need to be before global.pauseGame check so we can unpause
    if boss_phase == BossPhase.ASLEEP:
        unenemize()
        if cubeCrystal.get_ref() != null and cubeCrystal.get_ref().meshInstance1.visible:
            cubeCrystal.get_ref().meshInstance1.visible = false
            cubeCrystal.get_ref().ok_byebye = true
            global.memory["dogu_matryoshka_boss"] = -2
            miniShakeScreen()
            musicPlayer.stopAll()
        if global.memory["dogu_matryoshka_boss"] == -2:
            global.pauseGame = true
            global.shouldRenderAsCinematic = true
            global_transform.origin.y += (delta*11)
            if global_transform.origin.y >= -4.5:
                global_transform.origin.y = -4.5
                global.memory["dogu_matryoshka_boss"] = -1
        if global.memory["dogu_matryoshka_boss"] == -1:
            miniShakeScreen()
            asleep_unearth_counter = 0
            boss_phase = BossPhase.WAKEUP
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("wakeup")
            level.gameCamera.initial_size = 30
            level.gameCamera.zoomed_size = 30
            return
        if global.memory["dogu_matryoshka_boss"] == 1:
            cubeCrystal.get_ref().ok_byebye = true
            global_transform.origin.y += 10.5
            boss_phase = BossPhase.WAKEUP
            level.gameCamera.initial_size = 35
            level.gameCamera.zoomed_size = 35
    elif boss_phase == BossPhase.WAKEUP:
        if not secretAniPlayer.is_playing():
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            global.pauseGame = false
            global.shouldRenderAsCinematic = false
            secretAniPlayer.play("idleStand")
            boss_phase = BossPhase.IDLE
            if global.memory["dogu_matryoshka_boss"] == -1:
                global.memory["dogu_matryoshka_boss"] = 1
                level.restartMusic()
                level.uiLayer.setDisplayTitle(tr("UI.BossName.2"))
                level.gameCamera.initial_size = 35
                level.gameCamera.zoomed_size = 35
            return

    if cubeCrystal.get_ref() != null:
        cubeCrystal.get_ref().meshInstance1.visible = false
    if global.pauseGame:
        return

    if behavior_should_fall_rocks:
        fallingRockTimer += (delta*11)
        if fallingRockTimer >= fallingRockTimeLimit:
            fallingRockTimer = 0
            spawnFallingRock()
    else:
        fallingRockTimer = fallingRockTimeLimit

    # waddle around or stomp randomly, if NOSE is smacked, then do a jump and spin attack
    if boss_phase == BossPhase.IDLE:
        queueUpAJump()
        # waddle around or stomp randomly, if NOSE is smacked, then do a jump and spin attack
    elif boss_phase == BossPhase.WADDLE:
        # TODO(jaketrower): handle wall collision when waddling...
        behavior_walking = true
        waddle_timer += (delta*11)
        if waddle_timer >= waddle_time_limit:
            waddle_timer = 0
            behavior_walking = false
            walk_direction.x *= -1
            boss_phase = BossPhase.IDLE_STOMP
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("idleStomp")
            idle_stomp_timer = 0
    elif boss_phase == BossPhase.IDLE_STOMP:
        # enableAndPositionCautionWarning()
        behavior_walking = false
        behavior_should_fall_rocks = ("idleStomp" in secretAniPlayer.assigned_animation) or ("waddle" in secretAniPlayer.assigned_animation)
        if behavior_should_fall_rocks:
            idle_stomp_timer += (delta*11)
            if idle_stomp_timer >= idle_stomp_time_limit:
                idle_stomp_timer = 0
                boss_phase = BossPhase.WADDLE
                secretAniPlayer.stop()
                secretAniPlayer.clear_queue()
                if walk_direction.x > 0:
                    secretAniPlayer.play("waddle")
                else:
                    secretAniPlayer.play("waddleLeft")
                walk_direction.x *= -1
                queueUpAJump()
                waddle_timer = 0
                big_rock_counter += 1
        else:
            idle_stomp_timer = 0
    elif boss_phase == BossPhase.SPAWN_BIG_ROCK:
        if myBigRock != null and myBigRock.get_ref() != null:
            var bigRock = myBigRock.get_ref()
            var correctYPos = global_transform.origin.y + 11.5
            if bigRock.global_transform.origin.y <= correctYPos:
                bigRock.grav = Vector2(0, 0)
                bigRock.on_ground = true
                bigRock.global_transform.origin.y = correctYPos
                bigRock.is_big = false
                bigRock.landed()
                myBigRock = null
                tryToDeleteCautionWarning()
                secretAniPlayer.stop()
                secretAniPlayer.clear_queue()
                secretAniPlayer.play("dizzy")
                boss_phase = BossPhase.DIZZY
                thudSound.play()
                global_transform.origin.y -= 4
                spawnWeakEye()
        else:
            idle_stomp_timer += (delta*11)
            if idle_stomp_timer >= idle_stomp_time_limit:
                idle_stomp_timer = 0
                level.gameCamera.miniShakeScreen()
                var newBigRock = spawnFallingRock(global_transform.origin.x)
                newBigRock.scale = Vector3(2, 2, 1)
                newBigRock.is_big = true
                myBigRock = weakref(newBigRock)
    elif boss_phase == BossPhase.HURT:
        if not secretAniPlayer.is_playing():
            dizzy_timer = 0
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("idleStand")
            boss_phase = BossPhase.IDLE
            behavior_should_drill = not behavior_should_drill
    elif boss_phase == BossPhase.JUMP_SQUAT:
        behavior_should_fall_rocks = false
        if not secretAniPlayer.is_playing():
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("jumpFall")
            boss_phase = BossPhase.JUMP
            secretBounceAniPlayer.stop()
            secretBounceAniPlayer.clear_queue()
            secretBounceAniPlayer.play("jump")
    elif boss_phase == BossPhase.JUMP:
        behavior_should_fall_rocks = false
        behavior_jumping = true
        if not behavior_should_drill:
            behavior_walking = true
            if on_ground:
                if level.player.global_transform.origin.x > global_transform.origin.x:
                    walk_direction.x = 1
                else:
                    walk_direction.x = -1
        if vv < -2:
            behavior_jumping = false
            if behavior_should_drill:
                secretAniPlayer.stop()
                secretAniPlayer.clear_queue()
                secretAniPlayer.play("startDrillAttack")
                boss_phase = BossPhase.START_DRILL_ATTACK
            else:
                secretAniPlayer.stop()
                secretAniPlayer.clear_queue()
                secretAniPlayer.play("jumpFallEvil")
    elif boss_phase == BossPhase.START_DRILL_ATTACK:
        enableAndPositionCautionWarning()
        if not secretAniPlayer.is_playing():
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("drillAttackFall")
            boss_phase = BossPhase.DRILL_FALL
    elif boss_phase == BossPhase.DRILL_FALL:
        pass
    elif boss_phase == BossPhase.DRILL_DREIDEL_SPIN:
        enableAndPositionCautionWarning()
        smokeCloudTimer += (delta*11)
        if smokeCloudTimer >= 1:
            smokeCloudTimer = 0
            level.summonSmokeClouds(global_transform.origin, 2, false, true)

        if drillCharging:
            behavior_walking = true
            walk_speed = sin(dreidel_timer / (PI * 3)) + 1
            dreidel_timer += (delta*11)
            if dreidel_timer >= dreidel_charge_time_limit:
                dreidel_timer = 0
                drillCharging = false
            return

        behavior_walking = true
        dreidel_timer += (delta*11)
        walk_speed = 16 * sin(dreidel_timer / (PI * 3)) + 8
        # tryGetStunnedByWalls()
        if dreidel_timer >= dreidel_time_limit:
            behavior_walking = false
            dreidel_timer = 0
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("idleStand")
            tryToDeleteCautionWarning()
            behavior_should_drill = false
            boss_phase = BossPhase.IDLE
            spawnWorm()
            # secretAniPlayer.stop()
            # secretAniPlayer.clear_queue()
            # if global_transform.origin.x >= 8:
            #     secretAniPlayer.play("dizzy")
            # else:
            #     secretAniPlayer.play("dizzyRight")
            # boss_phase = BossPhase.DIZZY
    elif boss_phase == BossPhase.DIZZY:
        behavior_should_fall_rocks = false
        dizzy_timer += (delta*11)
        if dizzy_timer >= dizzy_time_limit:
            dizzy_timer = 0
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("idleStand")
            boss_phase = BossPhase.IDLE

    noseSprite.flip_h = mySprite.flip_h
    if cubeCrystal.get_ref() != null:
        cubeCrystal.get_ref().meshInstance1.visible = false

func queueUpAJump():
    walk_speed = 3*num_hits + 3
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("jumpSquat")
    secretBounceAniPlayer.stop()
    secretBounceAniPlayer.clear_queue()
    secretBounceAniPlayer.play("jumpSquat")
    boss_phase = BossPhase.JUMP_SQUAT
    tryToDeleteCautionWarning()

func unsmack():
    .unsmack()
    smack_time_limit = 10

onready var sillySound = get_node("Sounds/SillySound")
func getSmacked(broom_origin = null, silently = false, is_local_broom = false):
    should_modify_glitch_shader_vars = false
    if is_smacked or boss_phase == BossPhase.DRILL_DREIDEL_SPIN or boss_phase == BossPhase.DIZZY:
        return false

    sillySound.play()

    if boss_phase == BossPhase.ASLEEP:
        global_transform.origin.y += 1
        level.summonSmokeClouds(self.global_transform.origin, 3, false, false)
        level.summonSmokeClouds(self.global_transform.origin + Vector3(2, 0, 0), 3, false, false, global.grey_palette, 1)
        level.summonSmokeClouds(self.global_transform.origin + Vector3(-2, 0, 0), 3, false, false, global.grey_palette, -1)
        asleep_unearth_counter += 1
        if asleep_unearth_counter >= 4:
            global.pauseGame = true
            global.shouldRenderAsCinematic = true
            asleep_unearth_counter = 0
            boss_phase = BossPhase.WAKEUP
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("wakeup")
            level.gameCamera.initial_size = 30
            level.gameCamera.zoomed_size = 30
    elif boss_phase == BossPhase.DRILL_DREIDEL_SPIN:
        mySprite.material_override.set_shader_param("time_influence", time_influence*2)
        mySprite.material_override.set_shader_param("y_div", y_div*2)
        mySprite.material_override.set_shader_param("normal_offset", normal_offset*2)
        if should_modify_glitch_shader_vars:
            mySprite.material_override.set_shader_param("shake_power", 0.143*2)
            mySprite.material_override.set_shader_param("shake_block_size", 60*2)
            mySprite.material_override.set_shader_param("shake_color_rate", 0.219*2)
        smack_time_limit = 20
    elif boss_phase == BossPhase.DEFEATED:
        pass

    return .getSmacked(broom_origin, silently, is_local_broom)

var drillCharging = false
# @override
func landed(_was_on_fallthrough_solid = false):
    .landed()
    # getLevelTiles().purifyAllSoftSandSolids()

    miniShakeScreen()
    secretBounceAniPlayer.stop()
    secretBounceAniPlayer.clear_queue()
    secretBounceAniPlayer.play("land")
    if boss_phase == BossPhase.START_DRILL_ATTACK or boss_phase == BossPhase.DRILL_FALL or behavior_should_drill:
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        secretAniPlayer.play("drillAttackFall")
        if boss_phase != BossPhase.DRILL_DREIDEL_SPIN:
            spawnGhostEnemy()
            dreidel_timer = 0
            drillCharging = true
        boss_phase = BossPhase.DRILL_DREIDEL_SPIN
        # for _i in range(2):
        #     if digTiles(getTilesBelow(getLevelTiles()), true):
        #         global_transform.origin.y -= 8*.125
    if boss_phase == BossPhase.JUMP and not behavior_should_drill:
        spawnFallingRock(level.player.global_transform.origin.x)
        behavior_walking = false
        if num_hits == MAX_NUM_HITS - 1:
            spawnGhostEnemy()
        boss_phase = BossPhase.IDLE_STOMP
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        secretAniPlayer.play("idleLand")
        secretAniPlayer.queue("idleStomp")
        idle_stomp_timer = 0
        if big_rock_counter >= big_rock_count_max:
            idle_stomp_timer = 0
            boss_phase = BossPhase.SPAWN_BIG_ROCK
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("idleLand")
            secretAniPlayer.queue("idleStomp")
            level.gameCamera.miniShakeScreen()

        var tiles_underfoot = getTilesBelow(getLevelTiles())
        for tile_coords in tiles_underfoot:
            if tile_coords != null:
                var tile_type = getLevelTiles().get_cell_item(tile_coords.x, tile_coords.y, tile_coords.z)
                if getLevelTiles().isTileSoftSand(tile_type):
                    # getLevelTiles().infectSoftSand(tile_coords, false)
                    getLevelTiles().set_cell_item(tile_coords.x, tile_coords.y, tile_coords.z, GridMap.INVALID_CELL_ITEM)

# @override
func glitchSetSpritesAndCollision():
    pass
    # if boss_phase == BossPhase.FALL_OVER or boss_phase == BossPhase.STUN_TWITCH or boss_phase == BossPhase.GET_UP:
    #     return
    # spriteContainer.global_transform.origin.y = self.global_transform.origin.y + sprite_offset_y

# @override
func shouldIDoCollisions():
    .shouldIDoCollisions()
    should_collide_ceil = false

# @override
func doHorizontalWalkingBehavior():
    if behavior_walking and horizontal_collision:
        var solidTiles = []
        if walk_direction.x < 0:
            solidTiles = getTilesLeftOf(getLevelTiles(), 1.0)
        elif walk_direction.x > 0:
            solidTiles = getTilesRightOf(getLevelTiles(), 1.0)
        for i in range(solidTiles.size()):
            var coords = solidTiles[i]
            if coords == null: continue
        if global_transform.origin.x >= 24 or global_transform.origin.x <= -7:
            getSmacked()
            thudSound.play()
            horizontal_collision = false
            # if digTiles(getTilesBelow(getLevelTiles()), true):
            #     global_transform.origin.y -= 8*.125
            flipWalkingDirection()
            return
        
        horizontal_collision = false
        digTiles(solidTiles, true)

func digTiles(solidTiles, should_summon_clouds):
    var tiles_dug = 0
    if solidTiles[0] != null:
        var coords_a = solidTiles[0]
        var tile_type = levelTiles.get_cell_item(coords_a.x, coords_a.y, coords_a.z)
        if levelTiles.isTileSoftSand(tile_type):
            levelTiles.infectSoftSand(Vector3(coords_a.x, coords_a.y, coords_a.z), false)
            tiles_dug += 1
        elif not levelTiles.isTileFragileSolid(tile_type):
            levelTiles.removeTile(Vector3(coords_a.x, coords_a.y, coords_a.z), false)
            tiles_dug += 1
    if solidTiles[1] != null:
        var coords_mid = solidTiles[1]
        var tile_type = levelTiles.get_cell_item(coords_mid.x, coords_mid.y, coords_mid.z)
        if levelTiles.isTileSoftSand(tile_type):
            levelTiles.infectSoftSand(Vector3(coords_mid.x, coords_mid.y, coords_mid.z), false)
            tiles_dug += 1
        elif not levelTiles.isTileFragileSolid(tile_type):
            levelTiles.removeTile(Vector3(coords_mid.x, coords_mid.y, coords_mid.z), false)
            tiles_dug += 1
    if solidTiles[2] != null:
        var coords_b = solidTiles[2]
        var tile_type = levelTiles.get_cell_item(coords_b.x, coords_b.y, coords_b.z)
        if levelTiles.isTileSoftSand(tile_type):
            levelTiles.infectSoftSand(Vector3(coords_b.x, coords_b.y, coords_b.z), false)
            tiles_dug += 1
        elif not levelTiles.isTileFragileSolid(tile_type):
            levelTiles.removeTile(Vector3(coords_b.x, coords_b.y, coords_b.z), false)
            tiles_dug += 1

    if should_summon_clouds and tiles_dug > 0:
        level.summonSmokeClouds(global_transform.origin, 2)

    if tiles_dug > 0:
        digSound.play()
                
    return tiles_dug > 0

onready var wallStunCollisionShape = get_node("WallStunArea/CollisionShape")
func tryGetStunnedByWalls(margin = 0.25):
  var lt = getLevelTiles()

  var shape = wallStunCollisionShape
  var x = shape.global_transform.origin.x
  var y = shape.global_transform.origin.y
  var tb = y + shape.shape.extents.y/2*shape.scale.y + margin
  var bb = y - shape.shape.extents.y/2*shape.scale.y - margin
  var lb = x - shape.shape.extents.x/2*shape.scale.x - margin
  var rb = x + shape.shape.extents.x/2*shape.scale.x + margin
  
  lt.clearRandomTileTimers()
  for i in range(int(floor(bb)), int(ceil(tb))):
    for j in range(int(floor(lb)), int(ceil(rb))):
      var coords = getLevelTiles().world_to_map(Vector3(j, i, 0))
      # lt.rerandomizeTile(coords, lt.getRandomColorSuffix(), rand_timer)
      var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
      if lt.isTileSoftSand(tile_type):
        thudSound.play()
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        if walk_direction.x > 0:
            secretAniPlayer.play("dizzy")
        else:
            secretAniPlayer.play("dizzyRight")
        boss_phase = BossPhase.DIZZY
        behavior_walking = false
        levelTiles.purifyAllSoftSandSolids(true)
    #   if isTileFragileSolid():
        flipWalkingDirection()
        spawnWeakEye()

func spawnFallingRock(specific_x = null):
    var fallingRock = fallingRockRes.instance()
    fallingRock.true_terminal_vel = 12
    level.add_child(fallingRock)
    if specific_x != null:
        fallingRock.global_transform.origin.x = specific_x
    else:
        fallingRock.global_transform.origin.x = randi() % 34 - 7 # -7 to 24
    fallingRock.global_transform.origin.y = 16
    fallingRock.get_node("CautionWarning").scale = Vector3(0.7, 0.7, 1)
    return fallingRock

var ghostEnemies = []
func spawnGhostEnemy():
    var ghostEnemy = ghostEnemyRes.instance()
    ghostEnemy.moving_towards_player = true
    level.add_child(ghostEnemy)
    ghostEnemy.global_transform.origin.x = self.global_transform.origin.x
    ghostEnemy.global_transform.origin.y = self.global_transform.origin.y
    ghostEnemy.scared_time_limit = 60
    ghostEnemy.scared_timer = ghostEnemy.scared_time_limit - 10
    ghostEnemies.push_back(weakref(ghostEnemy))
    return ghostEnemy
    
func spawnWorm():
    var worm = wormRes.instance()
    worm.on_ground = false
    var jump_pop_val = 5
    worm.linear_velocity.y = jump_pop_val
    worm.lv.y = jump_pop_val
    worm.vv = worm.up.dot(worm.lv)
    level.add_child(worm)
    worm.global_transform.origin.x = self.global_transform.origin.x
    worm.global_transform.origin.y = self.global_transform.origin.y + 13
    worm.global_transform.origin.z = 0

func spawnWeakEye():
    var weakEye = weakEyeRes.instance()
    weakEye.is_static_in_level = false
    level.add_child(weakEye)
    weakEye.global_transform.origin = self.global_transform.origin
    weakEye.global_transform.origin.y += 8.465

func miniShakeScreen():
    level.gameCamera.miniShakeScreen()

func getHurt():
    level.player.glitchTickle()
    big_rock_counter = 0
    mySprite.visible = true
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("gotHurt")
    fallingRockTimeLimit /= 2
    num_hits += 1
    if cubeCrystal.get_ref() != null:
        if num_hits == 1:
            cubeCrystal.get_ref().getHitSound.play()
        elif num_hits == 2:
            cubeCrystal.get_ref().getHitSound2.play()
        elif num_hits == 3:
            cubeCrystal.get_ref().getHitSound3.play()
    if num_hits >= MAX_NUM_HITS:
        yaBeatMe()
    else:
        boss_phase = BossPhase.HURT

func yaBeatMe():
    behavior_should_fall_rocks = false
    behavior_should_drill = false
    behavior_walking = false
    behavior_jumping = false
    unenemize()
    boss_phase = BossPhase.DEFEATED
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("gotHurt")
    secretAniPlayer.queue("defeated")
    global.pauseGame = true
    global.shouldRenderAsCinematic = true
    if global.demo_mode <= 0: Steam.set_achievement("CLAYDOL_BOSS")

var crystalGeodeRes = preload("res://sceneObjects/CrystalGeode2.tscn")
func okayImDead():
    if global.memory["dogu_matryoshka_boss"] < 2:
        global.memory["dogu_matryoshka_boss"] = 2
        musicPlayer.stopAll()
        musicPlayer.playDefeatBossJingle()
        level.summonSmokeClouds(level.door.global_transform.origin, 2, true, true)
    for ghostEnemyRef in ghostEnemies:
        if ghostEnemyRef.get_ref():
            ghostEnemyRef.get_ref().moving_towards_player = false
            ghostEnemyRef.get_ref().getSmacked(level.player.global_transform.origin, true)
    global.pauseGame = false
    global.shouldRenderAsCinematic = false

    level.gameCamera.initial_size = 30
    level.gameCamera.zoomed_size = 30
    var newRealCrystal = crystalGeodeRes.instance()
    level.add_child(newRealCrystal)
    newRealCrystal.global_transform.origin = Vector3(8, -2, 0)
    level.summonSmokeClouds(newRealCrystal.global_transform.origin, 3, true, true, false)
    # level.door.visible = true
    level.levelTiles.tryToSayTidy()
    queue_free()

func updateFallthroughSolids():
    if fallthroughSolid:
        if boss_phase == BossPhase.ASLEEP:
            if fallthroughSolid.is_in_group("fallthrough"):
                fallthroughSolid.remove_from_group("fallthrough")
        elif not fallthroughSolid.is_in_group("fallthrough"):
            fallthroughSolid.add_to_group("fallthrough")
