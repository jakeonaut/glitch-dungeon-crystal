extends "../GlitchEnemy.gd"

onready var secretAniPlayer = get_node("SecretAnimationPlayer")
onready var secretBounceAniPlayer = get_node("SecretBounceAnimationPlayer")
onready var noseSprite = get_node("SpriteContainer/InnerSpriteContainer/NoseSprite")
onready var spriteContainer = get_node("SpriteContainer")
onready var thudSound = get_node("Sounds/ThudSound")
onready var digSound = get_node("Sounds/DigSound")
onready var cubeCrystal = get_node("CubeCrystal")

var MAX_NUM_HITS = 3
var num_hits = 0
var dreidel_timer = 0
var dreidel_time_limit = 40
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
var big_rock_count_max = 3
var myBigRock = null

func _ready():
    set_process(true)
    # sprite_offset_y = 7.5

# be careful cuz both the HurtPlayerArea and the InteractArea will both rely on this one function...
func isActive(debug = false):
    return .isActive(debug) and boss_phase != BossPhase.DIZZY

func _process(delta):
    noseSprite.flip_h = mySprite.flip_h
    # need to be before global.pauseGame check so we can unpause
    if boss_phase == BossPhase.ASLEEP:
        unenemize()
        if cubeCrystal.meshInstance1.visible:
            cubeCrystal.meshInstance1.visible = false
            global.memory["dogu_matryoshka_boss"] = -2
        if global.memory["dogu_matryoshka_boss"] == -2:
            global.pauseGame = true
            global.shouldRenderAsCinematic = true
            global_transform.origin.y += (delta*11)
            if global_transform.origin.y >= -4.5:
                global_transform.origin.y = -4.5
                global.memory["dogu_matryoshka_boss"] = -1
        if global.memory["dogu_matryoshka_boss"] == -1:
            asleep_unearth_counter = 0
            boss_phase = BossPhase.WAKEUP
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("wakeup")
            level.gameCamera.initial_size = 30
            level.gameCamera.zoomed_size = 30
            return
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
                level.uiLayer.setDisplayTitle("the Vessel of souls")
                level.gameCamera.initial_size = 35
                level.gameCamera.zoomed_size = 35
            return

    cubeCrystal.meshInstance1.visible = false
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
                bigRock.grav = 0
                bigRock.on_ground = true
                bigRock.global_transform.origin.y = correctYPos
                bigRock.is_big = false
                bigRock.landed()
                myBigRock = null
                secretAniPlayer.stop()
                secretAniPlayer.clear_queue()
                secretAniPlayer.play("dizzy")
                boss_phase = BossPhase.DIZZY
                thudSound.play()
                global_transform.origin.y -= 2
                spawnWeakEye()
        else:
            pass
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
            behavior_jumping = true
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("jumpFall")
            boss_phase = BossPhase.JUMP
            secretBounceAniPlayer.stop()
            secretBounceAniPlayer.clear_queue()
            secretBounceAniPlayer.play("jump")
    elif boss_phase == BossPhase.JUMP:
        behavior_should_fall_rocks = false
        if not behavior_should_drill:
            behavior_walking = true
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
        if not secretAniPlayer.is_playing():
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("drillAttackFall")
            boss_phase = BossPhase.DRILL_FALL
    elif boss_phase == BossPhase.DRILL_FALL:
        pass
    elif boss_phase == BossPhase.DRILL_DREIDEL_SPIN:
        smokeCloudTimer += (delta*11)
        if smokeCloudTimer >= 1:
            smokeCloudTimer = 0
            level.summonSmokeClouds(global_transform.origin, 2, false, true)

        behavior_walking = true
        dreidel_timer += (delta*11)
        walk_speed = 16 * sin(dreidel_timer / (PI * 3)) + 16
        # tryGetStunnedByWalls()
        if dreidel_timer >= dreidel_time_limit:
            behavior_walking = false
            dreidel_timer = 0
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("idleStand")
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
    cubeCrystal.meshInstance1.visible = false

func queueUpAJump():
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("jumpSquat")
    secretBounceAniPlayer.stop()
    secretBounceAniPlayer.clear_queue()
    secretBounceAniPlayer.play("jumpSquat")
    boss_phase = BossPhase.JUMP_SQUAT

func unsmack():
    .unsmack()
    smack_time_limit = 10

func getSmacked(broom_origin = null, silently = false):
    should_modify_glitch_shader_vars = false
    if is_smacked or boss_phase == BossPhase.DRILL_DREIDEL_SPIN or boss_phase == BossPhase.DIZZY:
        return false

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

    return .getSmacked(broom_origin, silently)

# @override
func landed():
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
        boss_phase = BossPhase.DRILL_DREIDEL_SPIN
        # for _i in range(2):
        #     if digTiles(getTilesBelow(getLevelTiles()), true):
        #         global_transform.origin.y -= 8*.125
    if boss_phase == BossPhase.JUMP and not behavior_should_drill:
        spawnFallingRock(level.player.global_transform.origin.x)
        behavior_walking = false
        boss_phase = BossPhase.IDLE_STOMP
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        secretAniPlayer.play("idlePause")
        secretAniPlayer.queue("idleStomp")
        idle_stomp_timer = 0
        if big_rock_counter >= big_rock_count_max:
            boss_phase = BossPhase.SPAWN_BIG_ROCK
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("idleStomp")
            level.gameCamera.shakeScreen()
            var newBigRock = spawnFallingRock(global_transform.origin.x)
            newBigRock.scale = Vector3(2, 2, 1)
            newBigRock.is_big = true
            myBigRock = weakref(newBigRock)

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
      # lt.rerandomizeTile(coords, lt.getRandomGlitchType(), rand_timer)
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
    return fallingRock

var ghostEnemies = []
func spawnGhostEnemy():
    var ghostEnemy = ghostEnemyRes.instance()
    ghostEnemy.moving_towards_player = true
    level.add_child(ghostEnemy)
    ghostEnemy.global_transform.origin.x = self.global_transform.origin.x
    ghostEnemy.global_transform.origin.y = self.global_transform.origin.y
    ghostEnemies.push_back(weakref(ghostEnemy))
    return ghostEnemy
    
func spawnWorm():
    var worm = wormRes.instance()
    worm.on_ground = false
    var jump_pop_val = 5
    worm.linear_velocity.y = jump_pop_val
    worm.lv.y = jump_pop_val
    worm.vv = jump_pop_val
    level.add_child(worm)
    worm.global_transform.origin.x = self.global_transform.origin.x
    worm.global_transform.origin.y = self.global_transform.origin.y + 13

func spawnWeakEye():
    var weakEye = weakEyeRes.instance()
    weakEye.is_static_in_level = false
    level.add_child(weakEye)
    weakEye.global_transform.origin = self.global_transform.origin
    weakEye.global_transform.origin.y += 8.465

func miniShakeScreen():
    level.gameCamera.miniShakeScreen()

func getHurt():
    big_rock_counter = 0
    mySprite.visible = true
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("gotHurt")
    fallingRockTimeLimit /= 2
    num_hits += 1
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

var crystalGeodeRes = preload("res://sceneObjects/CrystalGeode2.tscn")
func okayImDead():
    if global.memory["dogu_matryoshka_boss"] < 2:
        global.memory["dogu_matryoshka_boss"] = 2
        level.restartMusic()
    for ghostEnemyRef in ghostEnemies:
        if ghostEnemyRef.get_ref():
            ghostEnemyRef.get_ref().getSmacked(level.player.global_transform.origin, true)
    global.pauseGame = false
    global.shouldRenderAsCinematic = false

    var newRealCrystal = crystalGeodeRes.instance()
    level.add_child(newRealCrystal)
    newRealCrystal.global_transform.origin = Vector3(8, -2, 0)
    level.summonSmokeClouds(newRealCrystal.global_transform.origin, 3, true, true, false)
    level.summonSmokeClouds(level.door.global_transform.origin, 2, true, true)
    level.door.visible = true
    queue_free()

func updateFallthroughSolids():
    if fallthroughSolid:
        if boss_phase == BossPhase.ASLEEP:
            if fallthroughSolid.is_in_group("fallthrough"):
                fallthroughSolid.remove_from_group("fallthrough")
        elif not fallthroughSolid.is_in_group("fallthrough"):
            fallthroughSolid.add_to_group("fallthrough")
