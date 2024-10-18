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
}
var claw_machine_cycle = 0
var CLAW_MACHINE_CYCLE_MAX = 1
var boss_phase = BossPhase.IDLE

var original_pos = null
var target_pos = null
var lure_bullet_direction_vector = null
var BULLET_SPEED = 15
var cast_timer = 0
var cast_time_limit = 30
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

var num_hits = 0
func getHurt():
    mySprite.visible = true
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("gotHurt")

var preyTarget = null
func _process(delta):
    if global.pauseGame:
        return

    if boss_phase == BossPhase.IDLE:
        reenemize()
        if which_facing == 1:
            tryFlipLeft("idle")
        if lureAniPlayer.assigned_animation != "spinAttack":
            lureAniPlayer.stop()
            lureAniPlayer.clear_queue()
            lureAniPlayer.play("RESET")
        if target_pos != null and not (secretAniPlayer.assigned_animation == "gotHurt" and secretAniPlayer.is_playing()):
            moveAbout(delta)
        cast_timer += (delta*11)
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
            lureAniPlayer.play("spinAttack")
    elif boss_phase == BossPhase.CAST_LURE:
        lureFreeRange.global_transform.origin += lure_bullet_direction_vector * delta
        moveToSpecificPosition(delta, Vector3(6, 6, 0))
        lureFreeRange.global_transform.origin.x = lureContainer.global_transform.origin.x
        lureBulletTryDieToSolids()
        if lureFreeRange.hooked:
            boss_phase = BossPhase.REEL_IT_IN
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
        elif lureFreeRange.global_transform.origin.y < self.global_transform.origin.y - 8 and lureFreeRange.global_transform.origin.y <= level.player.global_transform.origin.y + 1:
            claw_machine_cycle = 0
            boss_phase = BossPhase.CLAW_MACHINE_FISHING_LEFT
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
    elif boss_phase == BossPhase.CLAW_MACHINE_FISHING_LEFT:
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
            fishLureSprite.scale = Vector3(1, 1, 1)
            lure_bullet_direction_vector = Vector3(0, BULLET_SPEED/2, 0)
            if lureFreeRange.hookTarget != null and lureFreeRange.hookTarget.get_ref() == level.player:
                unenemize()
        else:
            fishLureSprite.scale = Vector3(2, 2, 1)
            lure_bullet_direction_vector = Vector3(0, BULLET_SPEED, 0)

        # var pos = reelStopArea.global_transform.origin
        # var lure_pos = lureFreeRange.global_transform.origin
        lureFreeRange.global_transform.origin += lure_bullet_direction_vector * delta

        if lureFreeRange.hookInteractionArea.overlaps_area(reelStopArea) or lureFreeRange.global_transform.origin.y > global_transform.origin.y + 2.5:
            boss_phase = BossPhase.EAT_IT
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            lure_bullet_direction_vector = null
            if lureFreeRange.get_parent() == level:
                level.remove_child(lureFreeRange)
                lureContainer.add_child(lureFreeRange)
                lureFreeRange.global_transform.origin = lureContainer.global_transform.origin
                fishLureSprite.scale = Vector3(1, 1, 1)
                if lureFreeRange.hookTarget != null and lureFreeRange.hookTarget.get_ref() != null:
                    preyTarget = weakref(lureFreeRange.hookTarget.get_ref())
                    lureFreeRange.hooked = false
                    lureFreeRange.restorePlayer(true)
                    lureFreeRange.hookTarget = null
                    secretAniPlayer.play("chompDown")
                else:
                    secretAniPlayer.play("idle")
                    boss_phase = BossPhase.IDLE
    elif boss_phase == BossPhase.EAT_IT:
        if preyTarget != null and preyTarget.get_ref() != null:
            var prey = preyTarget.get_ref()
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

        if secretAniPlayer.assigned_animation == "chompDown" and not secretAniPlayer.is_playing():
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("idle")
            boss_phase = BossPhase.IDLE
    
    lureFreeRange.global_transform.origin.x = reelStopArea.global_transform.origin.x
    lureFreeRange.global_transform.origin.z = 0

func tryFlipLeft(nextIdle = "openIdle"):
    if secretAniPlayer.assigned_animation != "turnRightToLeft" and secretAniPlayer.assigned_animation != "openIdle":
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        which_facing = -1
        secretAniPlayer.play("turnRightToLeft")
        secretAniPlayer.queue(nextIdle)

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
        if prey == level.player:
            level.player.tryDieToEnemy(0, true, true, true)
            yield(get_tree().create_timer(0.1), "timeout")
            prey.visible = false
            yield(get_tree().create_timer(0.4), "timeout")
            prey.visible = true
            prey.pauseInput = false
        else:
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
    fishLureSprite.scale = Vector3(2, 2, 1)
    boss_phase = BossPhase.CAST_LURE
    if lureFreeRange.get_parent() == lureContainer:
        var temp_pos = lureFreeRange.global_transform.origin
        lureContainer.remove_child(lureFreeRange)
        level.add_child(lureFreeRange)
        lureFreeRange.global_transform.origin = temp_pos
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


func moveAbout(delta):
    var step = 1
    global_transform.origin = global_transform.origin + (target_pos - global_transform.origin) * (delta*step)
    
    if stepify(target_pos.x, 0.1) == stepify(global_transform.origin.x, 0.1) and \
       stepify(target_pos.y, 0.1) == stepify(global_transform.origin.y, 0.1):
        randomizeTargetPos()

    step = 2
    var crystal_target_pos_x = 0
    if mySprite.frame >= 2:
        crystal_target_pos_x = 1
    crystalsContainer.translation.x = crystalsContainer.translation.x + (crystal_target_pos_x - crystalsContainer.translation.x) * (delta*step)

func moveToSpecificPosition(delta, position, step = 1):
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

# @override
func handleCollisionsAndMove(_local_lv, _delta):
    return Vector3(0, 0, 0)
