extends "../GlitchEnemy.gd"

var spawnGlitchEffectRes = preload("res://sceneObjects/SpawnGlitchEffect.tscn")
var glitchEnemyRes = preload("res://sceneObjects/Enemies/GlitchEnemy.tscn")
var basicFrogEnemyRes = preload("res://sceneObjects/Enemies/BasicFrogEnemy.tscn")
var savePointRes = preload("res://sceneObjects/SavePoint.tscn")

onready var secretAniPlayer = get_node("SecretAnimationPlayer")
onready var crystalsContainer = get_node("Crystals")
onready var crystal1 = get_node("Crystals/HighpriestessCrystal")

onready var lureContainer = get_node("LureContainer")
onready var lureFreeRange = get_node("LureContainer/FreeRange")
onready var lureAniPlayer = get_node("LureContainer/FreeRange/AnimationPlayer")
onready var fishLureSprite = get_node("LureContainer/FreeRange/FishLureSprite")
onready var reelStopArea = get_node("LureContainer/ReelStopArea")
onready var weakPointContainer = get_node("WeakPointContainer")
onready var weakPointAniPlayer = get_node("WeakPointAnimationPlayer")

var num_hits = 0
var MAX_NUM_HITS = 3

enum BossPhase {
    IDLE,
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
    COUNTER_ATTACK,
    DEFEATED,
}
var claw_machine_cycle = 0
var CLAW_MACHINE_CYCLE_MAX = 1
var boss_phase = BossPhase.IDLE

var original_pos = null
var target_pos = null
var lure_bullet_direction_vector = null
var BULLET_SPEED = 15
var cast_timer = 0
var cast_time_limit = 60
var stun_timer = 0
var stun_time_limit = 240
var which_facing = -1

onready var spawnSound = get_node("Sounds/SpawnSound")
func _ready():
    set_process(true)
    # Wait two frames cuz idk
    yield(TempTimer.idle_frame(self), "timeout")
    yield(TempTimer.idle_frame(self), "timeout")
    original_pos = global_transform.origin
    randomizeTargetPos()

    crystal1.applyGlitchMaterial(5)
    behavior_phase_through_walls = true
    if lureFreeRange.get_parent() == lureContainer:
        lureContainer.remove_child(lureFreeRange)
        level.add_child(lureFreeRange)
        lureFreeRange.global_transform.origin = lureContainer.global_transform.origin

var preyTarget = null
func _process(delta):
    if global.pauseGame:
        return

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
            lureFreeRange.global_transform.origin.y = prey.global_transform.origin.y
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
            weakPointAniPlayer.stop()
            weakPointAniPlayer.clear_queue()
            weakPointAniPlayer.play("stunIdle")
            weakPointContainer.vulnerable = true
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
        if weakPointContainer.is_smacked:
            boss_phase = BossPhase.HURT
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("ouchies")
            weakPointAniPlayer.stop()
            weakPointAniPlayer.clear_queue()
            weakPointAniPlayer.play("ouchies")
            num_hits += 1
            if num_hits >= MAX_NUM_HITS:
                boss_phase = BossPhase.DEFEATED
                secretAniPlayer.queue("defeated")
                var temp_pos = crystal1.global_transform.origin
                crystalsContainer.remove_child(crystal1)
                level.add_child(crystal1)
                crystal1.global_transform.origin = temp_pos
                crystal1.is_goddess_dream_collectible = true
    elif boss_phase == BossPhase.HURT:
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
        if secretAniPlayer.assigned_animation == "defeated" and not secretAniPlayer.is_playing():
            pass
            
    
    if boss_phase != BossPhase.EAT_IT:
        lureFreeRange.global_transform.origin.x = lureContainer.global_transform.origin.x
    lureFreeRange.global_transform.origin.z = 0

func lureMatchPlayerY(delta):
    var step = 1
    var lerpedY = lureFreeRange.global_transform.origin.y
    var playerY = level.player.global_transform.origin.y
    lerpedY = lerpedY + (playerY - lerpedY) * (delta*step)
    lureFreeRange.global_transform.origin.y = lerpedY

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
            level.player.tryDieToEnemy(0, true, true, true)
            yield(get_tree().create_timer(0.1), "timeout")
            prey.visible = false
            yield(get_tree().create_timer(0.4), "timeout")
            prey.visible = true
            prey.pauseInput = false
        else:
            getSmacked(Vector3(0, 0, 0))
            boss_phase = BossPhase.STUN_FALL
            unenemize()
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("stunFall")
            tryToStartWeakPointDetachment()
            
            # i think the only other thing here is a GlitchEnemy?
            prey.ouchies(self.global_transform.origin)
            yield(get_tree().create_timer(0.1), "timeout")
            prey.queue_free()
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
        weakPointContainer.global_transform.origin = weakPointContainer.global_transform.origin + (target_pos - weakPointContainer.global_transform.origin) * (delta*step)
    
        if stepify(target_pos.x, 0.1) == stepify(weakPointContainer.global_transform.origin.x, 0.1) and \
           stepify(target_pos.y, 0.1) == stepify(weakPointContainer.global_transform.origin.y, 0.1):
            randomizeTargetPos()
        return
    global_transform.origin = global_transform.origin + (target_pos - global_transform.origin) * (delta*step)
    
    if stepify(target_pos.x, 0.1) == stepify(global_transform.origin.x, 0.1) and \
       stepify(target_pos.y, 0.1) == stepify(global_transform.origin.y, 0.1):
        randomizeTargetPos()

    step = 2
    var crystal_target_pos_x = 0
    if mySprite.frame >= 2:
        crystal_target_pos_x = 1
    crystalsContainer.translation.x = crystalsContainer.translation.x + (crystal_target_pos_x - crystalsContainer.translation.x) * (delta*step)

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
func tryDieToOffscreenCamera():
    pass

var bubbleHP = 5
# @override
func getSmacked(broom_origin = Vector3(0, 0, 0), silently = false):
    bubbleHP -= 1
    if bubbleHP <= 0:
        bubbleHP = 5
        boss_phase = BossPhase.STUN_FALL
        unenemize()
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        secretAniPlayer.play("stunFall")
        tryToStartWeakPointDetachment()
    time_influence = 35
    y_div = 5
    normal_offset = 0.5
    return .getSmacked(broom_origin, silently)


var is_weakpoint_attached = true
func tryToStartWeakPointDetachment():
    if is_weakpoint_attached and weakPointAniPlayer.assigned_animation != "detachSelf":
        weakPointAniPlayer.stop()
        weakPointAniPlayer.clear_queue()
        weakPointAniPlayer.play("detachSelf")
        weakPointAniPlayer.queue("swim")

func detachWeakPoint():
    if weakPointContainer.get_parent() != self:
        return
    var tempPos = weakPointContainer.global_transform.origin
    self.remove_child(weakPointContainer)
    level.summonSmokeClouds(tempPos, 1)
    level.add_child(weakPointContainer)
    is_weakpoint_attached = false
    weakPointContainer.global_transform.origin = tempPos