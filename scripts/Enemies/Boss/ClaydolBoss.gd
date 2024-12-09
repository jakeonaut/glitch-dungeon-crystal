extends "../GlitchEnemy.gd"

onready var secretAniPlayer = get_node("SecretAnimationPlayer")
onready var secretBounceAniPlayer = get_node("SecretBounceAnimationPlayer")
onready var crystalsContainer = get_node("Crystals")
onready var crystal1 = get_node("Crystals/HighpriestessCrystal")
onready var noseSprite = get_node("SpriteContainer/InnerSpriteContainer/NoseSprite")
onready var spriteContainer = get_node("SpriteContainer")
onready var thudSound = get_node("Sounds/ThudSound")
onready var digSound = get_node("Sounds/DigSound")

var MAX_NUM_HITS = 3
var num_hits = 0
var dreidel_timer = 0
var dreidel_time_limit = 40
var dizzy_timer = 0
var dizzy_time_limit = 60
var smokeCloudTimer = 0

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
    FALL_OVER,
    STUN_TWITCH,
    GET_UP,
}
var boss_phase = BossPhase.ASLEEP
var asleep_unearth_counter = 0
onready var spawnSound = get_node("Sounds/SpawnSound")
var weakEyeRes = preload("res://sceneObjects/Enemies/WeakEye.tscn")

func _ready():
    set_process(true)
    sprite_offset_y = 7.5

# be careful cuz both the HurtPlayerArea and the InteractArea will both rely on this one function...
func isActive(debug = false):
    return .isActive(debug) and boss_phase != BossPhase.DIZZY

func _process(delta):
    noseSprite.flip_h = mySprite.flip_h
    # need to be before global.pauseGame check so we can unpause
    if boss_phase == BossPhase.ASLEEP:
        if global.memory["dogu_matryoshka_boss"] == 1:
            global_transform.origin.y += 4
            global.pauseGame = true
            global.shouldRenderAsCinematic = true
            asleep_unearth_counter = 0
            boss_phase = BossPhase.WAKEUP
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("wakeup")
            level.gameCamera.initial_size = 30
            level.gameCamera.zoomed_size = 30
            return
        return
    elif boss_phase == BossPhase.WAKEUP:
        if not secretAniPlayer.is_playing():
            crystal1.applyGlitchMaterial(5)
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            global.pauseGame = false
            global.shouldRenderAsCinematic = false
            secretAniPlayer.play("idleStand")
            boss_phase = BossPhase.IDLE
            if global.memory["dogu_matryoshka_boss"] == 0:
                global.memory["dogu_matryoshka_boss"] = 1
                level.restartMusic()
                level.uiLayer.setDisplayTitle("the Vessel of souls")
            return

    if global.pauseGame:
        return
    # waddle around or stomp randomly, if NOSE is smacked, then do a jump and spin attack
    if boss_phase == BossPhase.IDLE:
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        secretAniPlayer.play("jumpSquat")
        secretBounceAniPlayer.stop()
        secretBounceAniPlayer.clear_queue()
        secretBounceAniPlayer.play("jumpSquat")
        boss_phase = BossPhase.JUMP_SQUAT
        # waddle around or stomp randomly, if NOSE is smacked, then do a jump and spin attack
    elif boss_phase == BossPhase.WADDLE:
        pass
    elif boss_phase == BossPhase.IDLE_STOMP:
        pass
    elif boss_phase == BossPhase.JUMP_SQUAT:
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
        if vv < -2:
            behavior_jumping = false
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("startDrillAttack")
            boss_phase = BossPhase.START_DRILL_ATTACK
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
        tryGetStunnedByWalls()
        if dreidel_timer >= dreidel_time_limit:
            behavior_walking = false
            dreidel_timer = 0
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("idleStand")
            boss_phase = BossPhase.IDLE
            # secretAniPlayer.stop()
            # secretAniPlayer.clear_queue()
            # if global_transform.origin.x >= 8:
            #     secretAniPlayer.play("dizzy")
            # else:
            #     secretAniPlayer.play("dizzyRight")
            # boss_phase = BossPhase.DIZZY
    elif boss_phase == BossPhase.DIZZY:
        dizzy_timer += (delta*11)
        if dizzy_timer >= dizzy_time_limit:
            dizzy_timer = 0
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("idleStand")
            boss_phase = BossPhase.IDLE
    elif boss_phase == BossPhase.FALL_OVER:
        unenemize()
        if not secretAniPlayer.is_playing():
            if secretAniPlayer.assigned_animation == "fallOver":
                secretAniPlayer.stop()
                secretAniPlayer.clear_queue()
                secretAniPlayer.play("stunTwitch")
            elif secretAniPlayer.assigned_animation == "fallOverRight":
                secretAniPlayer.stop()
                secretAniPlayer.clear_queue()
                secretAniPlayer.play("stunTwitchRight")
            boss_phase = BossPhase.STUN_TWITCH
    elif boss_phase == BossPhase.STUN_TWITCH:
        unenemize()

    noseSprite.flip_h = mySprite.flip_h

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

    # if boss_phase == BossPhase.DIZZY:
    #     boss_phase = BossPhase.FALL_OVER
    #     if secretAniPlayer.assigned_animation == "dizzy":
    #         secretAniPlayer.stop()
    #         secretAniPlayer.clear_queue()    
    #         secretAniPlayer.play("fallOver")
    #     elif secretAniPlayer.assigned_animation == "dizzyRight":
    #         secretAniPlayer.stop()
    #         secretAniPlayer.clear_queue()    
    #         secretAniPlayer.play("fallOverRight")

    return .getSmacked(broom_origin, silently)

# @override
func landed():
    .landed()
    secretBounceAniPlayer.stop()
    secretBounceAniPlayer.clear_queue()
    secretBounceAniPlayer.play("land")
    if boss_phase == BossPhase.START_DRILL_ATTACK or boss_phase == BossPhase.DRILL_FALL:
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        secretAniPlayer.play("drillAttackFall")
        boss_phase = BossPhase.DRILL_DREIDEL_SPIN
        dreidel_timer = 0
        for _i in range(2):
            if digTiles(getTilesBelow(getLevelTiles()), true):
                global_transform.origin.y -= 8*.125

# @override
func glitchSetSpritesAndCollision():
    if boss_phase == BossPhase.FALL_OVER or boss_phase == BossPhase.STUN_TWITCH or boss_phase == BossPhase.GET_UP:
        return
    spriteContainer.global_transform.origin.y = self.global_transform.origin.y + sprite_offset_y

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
            var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
            if getLevelTiles().isTileFragileSolid(tile_type):
                getSmacked()
                thudSound.play()
                horizontal_collision = false
                if digTiles(getTilesBelow(getLevelTiles()), true):
                    global_transform.origin.y -= 8*.125
                flipWalkingDirection()
                return
        
        horizontal_collision = false
        digTiles(solidTiles, true)

func digTiles(solidTiles, should_summon_clouds):
    var tiles_dug = 0
    if solidTiles[0] != null:
        var coords_a = solidTiles[0]
        var tile_type = levelTiles.get_cell_item(coords_a.x, coords_a.y, coords_a.z)
        if not levelTiles.isTileFragileSolid(tile_type):
            levelTiles.removeTile(Vector3(coords_a.x, coords_a.y, coords_a.z), false)
            tiles_dug += 1
    if solidTiles[1] != null:
        var coords_mid = solidTiles[1]
        var tile_type = levelTiles.get_cell_item(coords_mid.x, coords_mid.y, coords_mid.z)
        if not levelTiles.isTileFragileSolid(tile_type):
            levelTiles.removeTile(Vector3(coords_mid.x, coords_mid.y, coords_mid.z), false)
            tiles_dug += 1
    if solidTiles[2] != null:
        var coords_b = solidTiles[2]
        var tile_type = levelTiles.get_cell_item(coords_b.x, coords_b.y, coords_b.z)
        if not levelTiles.isTileFragileSolid(tile_type):
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

func spawnWeakEye():
    var weakEye = weakEyeRes.instance()
    weakEye.is_static_in_level = false
    level.add_child(weakEye)
    weakEye.global_transform.origin = self.global_transform.origin
    weakEye.global_transform.origin.y += 8.465

func getHurt():
    mySprite.visible = true
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("gotHurt")
    num_hits += 1
    if num_hits >= MAX_NUM_HITS:
        yaBeatMe()

func yaBeatMe():
    pass

func updateFallthroughSolids():
    if fallthroughSolid:
        if boss_phase == BossPhase.ASLEEP:
            if fallthroughSolid.is_in_group("fallthrough"):
                fallthroughSolid.remove_from_group("fallthrough")
        elif not fallthroughSolid.is_in_group("fallthrough"):
            fallthroughSolid.add_to_group("fallthrough")