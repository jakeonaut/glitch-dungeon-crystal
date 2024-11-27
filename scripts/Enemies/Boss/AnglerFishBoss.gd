extends "../GlitchEnemy.gd"

var basicFrogEnemyRes = preload("res://sceneObjects/Enemies/BasicFrogEnemy.tscn")

onready var secretAniPlayer = get_node("SecretAnimationPlayer")

onready var lureContainer = get_node("LureContainer")
onready var lureFreeRange = get_node("LureContainer/FreeRange")
onready var crystal = get_node("LureContainer/FreeRange/HighpriestessCrystal")
onready var lureAniPlayer = get_node("LureContainer/FreeRange/AnimationPlayer")
onready var reelStopArea = get_node("LureContainer/ReelStopArea")
onready var weakPointContainer = get_node("WeakPointContainer")
onready var weakPointAniPlayer = get_node("WeakPointContainer/WeakPointAnimationPlayer")
onready var weakPointTarget = get_node("WeakPointTarget")

var num_hits = 0
var MAX_NUM_HITS = 3

enum BossPhase {
    IDLE,
    LYING_IN_WAIT,
    WAKING_UP,
    WINDUP_CAST,
    CAST_LURE,
    CLAW_MACHINE_FISHING_LEFT,
    CLAW_MACHINE_FISHING_RIGHT,
    CLAW_MACHINE_FISHING_MIDDLE,
    REEL_IT_IN,
    EAT_IT,
    STUN_FALL,
    STUN_IDLE,
    HURT,
    DEFEATED,
}
var claw_machine_cycle = 0
var CLAW_MACHINE_CYCLE_MAX = 1
var boss_phase = BossPhase.LYING_IN_WAIT

var original_pos = null
var target_pos = null
var lure_bullet_direction_vector = null
var BULLET_SPEED = 15
var cast_timer = 0
var cast_time_limit = 60
var stun_timer = 0
var stun_time_limit = 240
var which_facing = -1
var is_weakpoint_attached = true

onready var spawnSound = get_node("Sounds/SpawnSound")
func _ready():
    set_process(true)
    # Wait two frames cuz idk
    yield(TempTimer.idle_frame(self), "timeout")
    yield(TempTimer.idle_frame(self), "timeout")
    original_pos = global_transform.origin
    randomizeTargetPos()

    behavior_phase_through_walls = true
    if lureFreeRange.get_parent() == lureContainer:
        var temp = lureFreeRange.global_transform.origin
        lureContainer.remove_child(lureFreeRange)
        level.add_child(lureFreeRange)
        lureFreeRange.global_transform.origin = temp

var preyTarget = null
func _process(delta):
    # need to be before global.pauseGame check so we can unpause
    if boss_phase == BossPhase.LYING_IN_WAIT:
        unenemize()
        if global.memory["angler_seaman_boss"] == 1:
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("openUp")
            secretAniPlayer.queue("fadeFromBlack")
            reenemize()
            boss_phase = BossPhase.WAKING_UP
            global.pauseGame = true
            global.shouldRenderAsCinematic = true
            level.gameCamera.initial_size = 30
            level.gameCamera.zoomed_size = 30
            pass
        return
    elif boss_phase == BossPhase.WAKING_UP:
        if not secretAniPlayer.is_playing():
            boss_phase = BossPhase.REEL_IT_IN
            global.shouldRenderAsCinematic = false
            global.pauseGame = false
            crystal.scale = Vector3(0.6, 0.6, 0.6)
            crystal.applyGlitchMaterial(5)
            if global.memory["angler_seaman_boss"] == 0:
                global.memory["angler_seaman_boss"] = 1
                musicPlayer.tryToPlay(musicPlayer.bossThemePlayer)
        return

    if global.pauseGame:
        return
    
    if boss_phase != BossPhase.STUN_IDLE and boss_phase != BossPhase.STUN_FALL:
        tryToReturnWeakPoint(delta)

    if boss_phase == BossPhase.IDLE:
        weakPointContainer.vulnerable = false
        lureFreeRange.global_transform.origin.y = lureContainer.global_transform.origin.y
        lureFreeRange.visible = true
        if which_facing == 1:
            tryFlipLeft("idle")
        if lureAniPlayer.assigned_animation != "shrink":
            lureAniPlayer.stop()
            lureAniPlayer.clear_queue()
            lureAniPlayer.play("shrink")
        if target_pos != null and not (secretAniPlayer.assigned_animation == "gotHurt" and secretAniPlayer.is_playing()):
            moveAbout(delta)
        cast_timer += (delta*11)
        if cast_timer >= 10:
            reenemize()
        if cast_timer >= cast_time_limit:
            cast_timer = 0
            boss_phase = BossPhase.WINDUP_CAST
    elif boss_phase == BossPhase.WINDUP_CAST:
        if secretAniPlayer.assigned_animation != "castRod":
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("castRod")
            lureAniPlayer.stop()
            lureAniPlayer.clear_queue()
            lureAniPlayer.queue("grow")
            lureAniPlayer.queue("spinAttack")
        lureFreeRange.global_transform.origin.y = lureContainer.global_transform.origin.y
    elif boss_phase == BossPhase.CAST_LURE:
        lureFreeRange.global_transform.origin += lure_bullet_direction_vector * delta
        moveToSpecificPosition(delta, Vector3(6, 6, 0))
        # lureBulletTryDieToSolids()
        if lureFreeRange.hooked:
            boss_phase = BossPhase.REEL_IT_IN
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
        elif lureFreeRange.global_transform.origin.y < self.global_transform.origin.y - 4:
            claw_machine_cycle = 0
            boss_phase = BossPhase.CLAW_MACHINE_FISHING_LEFT
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
    elif boss_phase == BossPhase.CLAW_MACHINE_FISHING_LEFT:
        lureMatchPlayerY(delta)
        tryFlipLeft()
        if lureFreeRange.hooked:
            boss_phase = BossPhase.REEL_IT_IN
            return
        if moveToSpecificPosition(delta, Vector3(-2, 6, 0), 2) or global_transform.origin.x < -1:
            boss_phase = BossPhase.CLAW_MACHINE_FISHING_RIGHT
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("cheat")
        lureFreeRange.global_transform.origin.x = lureContainer.global_transform.origin.x
    elif boss_phase == BossPhase.CLAW_MACHINE_FISHING_RIGHT:
        lureMatchPlayerY(delta)
        tryFlipRight()
        if lureFreeRange.hooked:
            boss_phase = BossPhase.REEL_IT_IN
            return
        if moveToSpecificPosition(delta, Vector3(15, 6, 0), 2) or global_transform.origin.x > 14:
            if claw_machine_cycle < CLAW_MACHINE_CYCLE_MAX:
                boss_phase = BossPhase.CLAW_MACHINE_FISHING_LEFT
            else:
                boss_phase = BossPhase.CLAW_MACHINE_FISHING_MIDDLE
            claw_machine_cycle += 1
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("cheat")
        lureFreeRange.global_transform.origin.x = lureContainer.global_transform.origin.x
    elif boss_phase == BossPhase.CLAW_MACHINE_FISHING_MIDDLE:
        lureMatchPlayerY(delta)
        tryFlipLeft()
        if lureFreeRange.hooked:
            boss_phase = BossPhase.REEL_IT_IN
            return
        if moveToSpecificPosition(delta, Vector3(6, 6, 0), 2):
            boss_phase = BossPhase.REEL_IT_IN
            return
        lureFreeRange.global_transform.origin.x = lureContainer.global_transform.origin.x
    elif boss_phase == BossPhase.REEL_IT_IN:
        if lureFreeRange.hooked:
            lure_bullet_direction_vector = Vector3(0, BULLET_SPEED/2, 0)
            if lureFreeRange.hookTarget != null and lureFreeRange.hookTarget.get_ref() != null:
                if lureFreeRange.hookTarget.get_ref() == level.player:
                    unenemize()
                else:
                    unenemize()
                    preyTarget = weakref(lureFreeRange.hookTarget.get_ref())
                    lureFreeRange.hooked = false
                    lureFreeRange.restorePlayer(true)
                    lureFreeRange.hookTarget = null
                    preyTarget.get_ref().grav = 0
                    preyTarget.get_ref().behavior_walking = false
                    secretAniPlayer.stop()
                    secretAniPlayer.clear_queue()
                    secretAniPlayer.play("stunFall")
                    evolveSound.play()
                    gotcha()
        else:
            lure_bullet_direction_vector = Vector3(0, BULLET_SPEED, 0)

        # var pos = reelStopArea.global_transform.origin
        # var lure_pos = lureFreeRange.global_transform.origin
        lureFreeRange.global_transform.origin += lure_bullet_direction_vector * delta

        if lureFreeRange.hookInteractionArea.overlaps_area(reelStopArea) or lureFreeRange.global_transform.origin.y > global_transform.origin.y + 2.5:
            boss_phase = BossPhase.EAT_IT
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            lure_bullet_direction_vector = null
            if lureFreeRange.hookTarget != null and lureFreeRange.hookTarget.get_ref() != null:
                preyTarget = weakref(lureFreeRange.hookTarget.get_ref())
                lureFreeRange.hooked = false
                lureFreeRange.restorePlayer(true)
                lureFreeRange.hookTarget = null
                if preyTarget.get_ref() == level.player:
                    secretAniPlayer.play("chompDown")
                    weakPointAniPlayer.stop()
                    weakPointAniPlayer.clear_queue()
                    weakPointAniPlayer.play("chompDown")
                else:
                    secretAniPlayer.play("chompDownQuick")
                    preyTarget.get_ref().grav = 0
                    preyTarget.get_ref().behavior_walking = false
            else:
                secretAniPlayer.play("idle")
                weakPointAniPlayer.stop()
                weakPointAniPlayer.clear_queue()
                weakPointAniPlayer.play("idle")
                boss_phase = BossPhase.IDLE
                cast_timer = 0
    elif boss_phase == BossPhase.EAT_IT:
        if preyTarget != null and preyTarget.get_ref() != null:
            var prey = preyTarget.get_ref()
            # lureFreeRange.global_transform.origin.y = prey.global_transform.origin.y
            if prey == level.player:
                level.player.hv = Vector3(0, 0, 0)
                level.player.dir = Vector3(0.0, 0.0, 0.0)
                level.player.linear_velocity.x = 0
                level.player.lv.x = 0
                level.player.pauseAnimation = false
                level.player.vv = 0
                level.player.linear_velocity.y = 0
                level.player.lv.y = 0
                if not prey.pauseInput:
                    level.player.gravitySound.play()
                level.player.glitchTickle()
                prey.pauseInput = true
        if "chompDown" in secretAniPlayer.assigned_animation and not secretAniPlayer.is_playing():
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("idle")
            weakPointAniPlayer.stop()
            weakPointAniPlayer.clear_queue()
            weakPointAniPlayer.play("idle")
            boss_phase = BossPhase.IDLE
            cast_timer = 0
            lureFreeRange.visible = true
    elif boss_phase == BossPhase.STUN_FALL:
        grav = 60
        on_ground = false
        if global_transform.origin.y <= -5:
            grav = 0
            global_transform.origin.y = -5
            boss_phase = BossPhase.STUN_IDLE
            level.player.bumpSound.play()
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("stunIdle")
            stun_timer = 0
    elif boss_phase == BossPhase.STUN_IDLE:
        if not is_weakpoint_attached:
            moveAbout(delta, true) # move the baby
        stun_timer += (delta * 11)
        if stun_timer >= stun_time_limit:
            stun_timer = 0
            boss_phase = BossPhase.IDLE
            cast_timer = 0
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("idle")
            weakPointAniPlayer.stop()
            weakPointAniPlayer.clear_queue()
            weakPointAniPlayer.play("idle")
    elif boss_phase == BossPhase.HURT:
        global_transform.origin.y += (delta*11)
        if not secretAniPlayer.is_playing():
            boss_phase = BossPhase.IDLE
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("idle")
            weakPointAniPlayer.stop()
            weakPointAniPlayer.clear_queue()
            weakPointAniPlayer.play("idle")
    elif boss_phase == BossPhase.DEFEATED:
        moveToSpecificPosition(delta, Vector3(6, 6, 0))
        # if secretAniPlayer.assigned_animation == "defeated" and not secretAniPlayer.is_playing():
        #     pass
        # self.rotation_degrees.y += delta*22
            
    
    if boss_phase != BossPhase.EAT_IT:
        lureFreeRange.global_transform.origin.x = lureContainer.global_transform.origin.x
    lureFreeRange.global_transform.origin.z = 0

func startBossFight(_was_player_caught):
    if boss_phase != BossPhase.LYING_IN_WAIT:
        return false
    level.player.aniPlayer.stop()
    level.player.aniPlayer.clear_queue()
    level.player.aniPlayer.queue("fall")
    if level.player.summonedBroom:
        level.player.broomStop()

    global.pauseGame = true
    global.shouldRenderAsCinematic = true
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("fadeFromBlack")
    secretAniPlayer.queue("2secondPause")
    secretAniPlayer.queue("openUp")
    secretAniPlayer.queue("2secondPause")
    boss_phase = BossPhase.WAKING_UP
    level.gameCamera.initial_size = 30
    level.gameCamera.zoomed_size = 30

var lure_up_down_dir = Vector2(0, -1)
func lureMatchPlayerY(delta):
    # don't actually match player Y
    # var step = 1
    # var lerpedY = lureFreeRange.global_transform.origin.y
    # var playerY = level.player.global_transform.origin.y
    # lerpedY = lerpedY + (playerY - lerpedY) * (delta*step)
    # lureFreeRange.global_transform.origin.y = lerpedY
    var bottom_length = lureContainer.global_transform.origin.y - 12
    var top_length = lureContainer.global_transform.origin.y - 6
    var speed = 1
    if lure_up_down_dir.y < 0:
        lureFreeRange.global_transform.origin.y -= (speed * delta * 11)
        if lureFreeRange.global_transform.origin.y <= bottom_length:
            lureFreeRange.global_transform.origin.y = bottom_length
            lure_up_down_dir.y = 1
    elif lure_up_down_dir.y > 0:
        lureFreeRange.global_transform.origin.y += (speed * delta * 11)
        if lureFreeRange.global_transform.origin.y >= top_length:
            lureFreeRange.global_transform.origin.y = top_length
            lure_up_down_dir.y = -1



func tryFlipLeft(nextIdle = "openIdle"):
    if secretAniPlayer.assigned_animation != "turnRightToLeft" and secretAniPlayer.assigned_animation != "openIdle":
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        which_facing = -1
        secretAniPlayer.play("turnRightToLeft")
        secretAniPlayer.queue(nextIdle)
        weakPointAniPlayer.stop()
        weakPointAniPlayer.clear_queue()
        weakPointAniPlayer.play("turnRightToLeft")
        if nextIdle == "idle":
            weakPointAniPlayer.queue(nextIdle)

func tryFlipRight():
    if secretAniPlayer.assigned_animation != "turnLeftToRight" and secretAniPlayer.assigned_animation != "openIdle":
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        secretAniPlayer.play("turnLeftToRight")
        which_facing = 1
        secretAniPlayer.queue("openIdle")

func teleportToPrey():
    if preyTarget != null and preyTarget.get_ref() != null:
        var prey = preyTarget.get_ref()
        if which_facing == -1:
            global_transform.origin = prey.global_transform.origin + Vector3(2, -0.361, 0)
        else:
            global_transform.origin = prey.global_transform.origin + Vector3(-2, -0.361, 0)

func gotcha():
    if preyTarget != null and preyTarget.get_ref() != null:
        var prey = preyTarget.get_ref()
        lureFreeRange.visible = false
        if prey == level.player:
            if level.player.malware_infected:
                boss_phase = BossPhase.STUN_FALL
                unenemize()
                secretAniPlayer.stop()
                secretAniPlayer.clear_queue()
                secretAniPlayer.play("stunFall")
                tryToStartWeakPointDetachment()
                level.player.on_ground = false
                lureFreeRange.restorePlayer(false)
                level.player.on_ground = false
                level.player.bigBump()
                # level.player.malwareCured()
                level.player.pauseInput = false
                level.player.on_ground = false
            else:
                level.player.tryDieToEnemy(0, true, true, true)
                yield(get_tree().create_timer(0.1), "timeout")
                level.player.visible = false
                yield(get_tree().create_timer(0.4), "timeout")
                level.player.visible = true
                level.player.pauseInput = false
    preyTarget = null

func doLureCast():
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("openUp")
    secretAniPlayer.queue("openIdle")
    boss_phase = BossPhase.CAST_LURE
    # var player_pos = level.player.global_transform.origin
    # var lure_pos = lureContainer.global_transform.origin
    lure_bullet_direction_vector = Vector3(0, -BULLET_SPEED, 0)

func lureBulletTryDieToSolids():
    if boss_phase != BossPhase.CAST_LURE:
        return

    var x = lureFreeRange.global_transform.origin.x
    var y = lureFreeRange.global_transform.origin.y
    
    var coords_a = getLevelTiles().world_to_map(Vector3(x, y, 0))
    var tile_type_a = getLevelTiles().get_cell_item(coords_a.x, coords_a.y, coords_a.z)

    if getLevelTiles().isTileSolid(tile_type_a):
        boss_phase = BossPhase.REEL_IT_IN


func moveAbout(delta, moveTheBaby = false):
    var step = 1
    if moveTheBaby:
        step = 3
        weakPointContainer.global_transform.origin = weakPointContainer.global_transform.origin + (target_pos - weakPointContainer.global_transform.origin) * (delta*step)
    
        if stepify(target_pos.x, 0.1) == stepify(weakPointContainer.global_transform.origin.x, 0.1) and \
           stepify(target_pos.y, 0.1) == stepify(weakPointContainer.global_transform.origin.y, 0.1):
            randomizeTargetPos()
        return
    global_transform.origin = global_transform.origin + (target_pos - global_transform.origin) * (delta*step)
    
    if stepify(target_pos.x, 0.1) == stepify(global_transform.origin.x, 0.1) and \
       stepify(target_pos.y, 0.1) == stepify(global_transform.origin.y, 0.1):
        randomizeTargetPos()

func moveToSpecificPosition(delta, position, step = 1, moveTheBaby = false):
    if moveTheBaby:
        weakPointContainer.global_transform.origin = weakPointContainer.global_transform.origin + (position - weakPointContainer.global_transform.origin) * (delta*step)
        if stepify(position.x, 0.1) == stepify(weakPointContainer.global_transform.origin.x, 0.1) and \
        stepify(position.y, 0.1) == stepify(weakPointContainer.global_transform.origin.y, 0.1):
            return true
        return false
    global_transform.origin = global_transform.origin + (position - global_transform.origin) * (delta*step)
    if stepify(position.x, 0.1) == stepify(global_transform.origin.x, 0.1) and \
       stepify(position.y, 0.1) == stepify(global_transform.origin.y, 0.1):
        return true
    return false

func randomizeTargetPos():
    target_pos = Vector3(
        original_pos.x + rand_range(-5, 5),
        original_pos.y + rand_range(-3, 5),
        original_pos.z
    )

# @override
func tryDieToOffscreenCamera(_delta):
    pass

# var bubbleHP = 5 # should slowly "glitch" the crystal and then corrupt him??
# @override
func getSmacked(broom_origin = null, silently = false):
    if boss_phase == BossPhase.DEFEATED or boss_phase == BossPhase.HURT:
        return false

    if boss_phase == BossPhase.LYING_IN_WAIT or boss_phase == BossPhase.EAT_IT:
        return false

    if boss_phase == BossPhase.STUN_FALL or boss_phase == BossPhase.STUN_IDLE:
        time_influence = 35
        y_div = 5
        normal_offset = 0.5
        return .getSmacked(broom_origin, silently)

    boss_phase = BossPhase.EAT_IT
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    lure_bullet_direction_vector = null
    preyTarget = weakref(level.player)
    # lureFreeRange.hooked = false
    # lureFreeRange.restorePlayer(true)
    # lureFreeRange.hookTarget = null
    secretAniPlayer.play("chompDown")
    weakPointAniPlayer.stop()
    weakPointAniPlayer.clear_queue()
    weakPointAniPlayer.play("chompDown")
    return false
    # bubbleHP -= 1
    # if bubbleHP <= 0:
    #     bubbleHP = 5
    #     boss_phase = BossPhase.STUN_FALL
    #     unenemize()
    #     secretAniPlayer.stop()
    #     secretAniPlayer.clear_queue()
    #     secretAniPlayer.play("stunFall")
    #     tryToStartWeakPointDetachment()
    

func tryToStartWeakPointDetachment():
    if num_hits <= 0:
        if weakPointAniPlayer.assigned_animation != "ouchies" and weakPointAniPlayer.assigned_animation != "stunIdleAttached":
            weakPointAniPlayer.stop()
            weakPointAniPlayer.clear_queue()
            weakPointAniPlayer.play("ouchies")
            weakPointAniPlayer.queue("stunIdleAttached")
        return
    if is_weakpoint_attached and weakPointAniPlayer.assigned_animation != "detachSelf":
        weakPointAniPlayer.stop()
        weakPointAniPlayer.clear_queue()
        weakPointAniPlayer.play("detachSelf")
        weakPointAniPlayer.queue("stunIdle")

func makeWeakPointVulnerable():
    weakPointContainer.vulnerable = true

func detachWeakPoint():
    if weakPointContainer.get_parent() != self:
        return
    self.remove_child(weakPointContainer)
    level.summonSmokeClouds(weakPointTarget.global_transform.origin, 1)
    level.add_child(weakPointContainer)
    is_weakpoint_attached = false
    weakPointContainer.global_transform.origin = weakPointTarget.global_transform.origin
    weakPointContainer.vulnerable = true

func tryToReturnWeakPoint(delta):
    if is_weakpoint_attached:
        weakPointContainer.global_transform.origin = weakPointTarget.global_transform.origin
        weakPointContainer.vulnerable = false
        return
    var step = 3 if boss_phase == BossPhase.DEFEATED else 6
    weakPointContainer.global_transform.origin = weakPointContainer.global_transform.origin + (weakPointTarget.global_transform.origin - weakPointContainer.global_transform.origin) * (delta*step)
    
    if stepify(weakPointTarget.global_transform.origin.x, 0.1) == stepify(weakPointContainer.global_transform.origin.x, 0.1) and \
        stepify(weakPointTarget.global_transform.origin.y, 0.1) == stepify(weakPointContainer.global_transform.origin.y, 0.1):
        reattachWeakPoint()
    return

func reattachWeakPoint():
    if weakPointContainer.get_parent() == self:
        return
    level.remove_child(weakPointContainer)
    level.summonSmokeClouds(weakPointTarget.global_transform.origin, 1)
    self.add_child(weakPointContainer)
    is_weakpoint_attached = true
    weakPointContainer.global_transform.origin = weakPointTarget.global_transform.origin
    weakPointContainer.vulnerable = false
    if boss_phase == BossPhase.DEFEATED:
        global.memory["angler_seaman_boss"] = 2
        global.pauseGame = false
        global.shouldRenderAsCinematic = false
        queue_free()

func defeatMe():
    boss_phase = BossPhase.DEFEATED
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("ouchies")
    secretAniPlayer.queue("defeated")
    global.pauseGame = true
    global.shouldRenderAsCinematic = true

    if lureFreeRange.get_parent() == lureContainer:
        var temp = lureFreeRange.global_transform.origin
        lureContainer.remove_child(lureFreeRange)
        level.add_child(lureFreeRange)
        lureFreeRange.global_transform.origin = temp
