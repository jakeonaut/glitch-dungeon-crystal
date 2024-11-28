extends "../GlitchEnemy.gd"

var basicFrogEnemyRes = preload("res://sceneObjects/Enemies/BasicFrogEnemy.tscn")

onready var secretAniPlayer = get_node("SecretAnimationPlayer")

onready var cubeCrystal = get_node("CubeCrystal")
onready var fakeCrystalContainer = get_node("FakeCrystals")
onready var weakPointContainer = get_node("WeakPointContainer")
onready var weakPointAniPlayer = get_node("WeakPointContainer/WeakPointAnimationPlayer")
onready var weakPointTarget = get_node("WeakPointTarget")
var crystalGeodeRes = preload("res://sceneObjects/CrystalGeode2.tscn")

var num_hits = 0
var MAX_NUM_HITS = 3

enum BossPhase {
    IDLE,
    LYING_IN_WAIT,
    WAKING_UP,
    PREPARING_CHARGE,
    CHARGING,
    HIDING_WITH_DUPLICATES,
    EAT_IT,
    STUN_FALL,
    STUN_IDLE,
    HURT,
    DEFEATED,
}
var boss_phase = BossPhase.LYING_IN_WAIT

var original_pos = null
var target_pos = null
var lure_bullet_direction_vector = null
var BULLET_SPEED = 15
var idle_timer = 0
var idle_time_limit = 20
var charging_time_limit = 30
var crystal_appear_time_limit = 10
var stun_timer = 0
var stun_time_limit = 240
var is_weakpoint_attached = true
var crystalLandings = []
var which_three = []

onready var spawnSound = get_node("Sounds/SpawnSound")
func _ready():
    set_process(true)
    is_sprite_flipped = true
    # Wait two frames cuz idk
    yield(TempTimer.idle_frame(self), "timeout")
    yield(TempTimer.idle_frame(self), "timeout")
    original_pos = global_transform.origin
    randomizeTargetPos()
    crystalLandings = level.get_tree().get_nodes_in_group("crystal_landing")

    behavior_phase_through_walls = true
    walk_speed = 16

    self.remove_child(fakeCrystalContainer)
    level.add_child(fakeCrystalContainer)

var preyTarget = null
func _process(delta):
    # need to be before global.pauseGame check so we can unpause
    if boss_phase == BossPhase.LYING_IN_WAIT:
        unenemize()
        if cubeCrystal.meshInstance1.visible:
            cubeCrystal.meshInstance1.visible = false
            global.memory["angler_seaman_boss"] = 1 
        if global.memory["angler_seaman_boss"] == 1:
            startBossFight()
        return
    elif boss_phase == BossPhase.WAKING_UP:
        if not secretAniPlayer.is_playing():
            boss_phase = BossPhase.IDLE
            global.shouldRenderAsCinematic = false
            global.pauseGame = false
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("idle")
            weakPointAniPlayer.stop()
            weakPointAniPlayer.clear_queue()
            weakPointAniPlayer.play("idle")
            # cubeCrystal.applyGlitchMaterial(5)
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
        if target_pos != null and not (secretAniPlayer.assigned_animation == "gotHurt" and secretAniPlayer.is_playing()):
            moveAbout(delta)
        idle_timer += (delta*11)
        if idle_timer >= 10:
            reenemize()
        if idle_timer >= idle_time_limit:
            idle_timer = 0
            boss_phase = BossPhase.PREPARING_CHARGE
    elif boss_phase == BossPhase.PREPARING_CHARGE:
        if secretAniPlayer.assigned_animation != "openUp" and secretAniPlayer.assigned_animation != "openIdle":
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("openUp")
            secretAniPlayer.queue("openIdle")
        # this position is stupid and specific to the level I'm in... oh well
        moveToSpecificPosition(delta, Vector3(65, level.player.global_transform.origin.y, 0), 1, false)
        idle_timer += (delta*11)
        if idle_timer >= charging_time_limit:
            idle_timer = 0
            boss_phase = BossPhase.CHARGING
    elif boss_phase == BossPhase.CHARGING:
        behavior_walking = true
        walk_direction.x = -1
        # this is stupid and specific to the level I'm in... oh well
        if global_transform.origin.x < 16.134:
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("fadeToBlack")
            behavior_walking = false
            boss_phase = BossPhase.HIDING_WITH_DUPLICATES
            which_three = []
            crystalLandings.shuffle()
            which_three.push_back(crystalLandings[0])
            which_three.push_back(crystalLandings[1])
            which_three.push_back(crystalLandings[2])
    elif boss_phase == BossPhase.HIDING_WITH_DUPLICATES:
        unenemize()
        if which_three.size() > 0:
            idle_timer += (delta*11)
            if idle_timer >= crystal_appear_time_limit:
                idle_timer = 0
                var crystalLanding = which_three.pop_back()
                if which_three.size() == 0:
                    global_transform.origin = crystalLanding.global_transform.origin
                    global_transform.origin.x += 6
                    global_transform.origin.y -= 1.5
                else:
                    var newFakeCrystal = crystalGeodeRes.instance()
                    newFakeCrystal.is_fake = true
                    fakeCrystalContainer.add_child(newFakeCrystal)
                    newFakeCrystal.global_transform.origin = crystalLanding.global_transform.origin

        if cubeCrystal.meshInstance1.visible:
            cubeCrystal.meshInstance1.visible = false
            boss_phase = BossPhase.IDLE
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("fadeFromBlack")
            secretAniPlayer.queue("idle")
            weakPointAniPlayer.stop()
            weakPointAniPlayer.clear_queue()
            weakPointAniPlayer.play("idle")

            var fakeCrystals = fakeCrystalContainer.get_children()
            for fakeCrystal in fakeCrystals:
                fakeCrystalContainer.remove_child(fakeCrystal)
                fakeCrystal.queue_free()
            

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
        if "chompDown" in secretAniPlayer.assigned_animation and not secretAniPlayer.is_playing():
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("idle")
            weakPointAniPlayer.stop()
            weakPointAniPlayer.clear_queue()
            weakPointAniPlayer.play("idle")
            boss_phase = BossPhase.IDLE
            idle_timer = 0
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
            idle_timer = 0
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
    cubeCrystal.meshInstance1.visible = false

func startBossFight():
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

func teleportToPrey():
    if preyTarget != null and preyTarget.get_ref() != null:
        var prey = preyTarget.get_ref()
        global_transform.origin = prey.global_transform.origin + Vector3(2, -0.361, 0)

func gotcha():
    if preyTarget != null and preyTarget.get_ref() != null:
        var prey = preyTarget.get_ref()
        if prey == level.player:
            if level.player.malware_infected:
                boss_phase = BossPhase.STUN_FALL
                unenemize()
                secretAniPlayer.stop()
                secretAniPlayer.clear_queue()
                secretAniPlayer.play("stunFall")
                tryToStartWeakPointDetachment()
                level.player.on_ground = false
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
    secretAniPlayer.play("chompDown")
    weakPointAniPlayer.stop()
    weakPointAniPlayer.clear_queue()
    weakPointAniPlayer.play("chompDown")
    return false
    

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

# @override
func actuallyDieToOffscreenCamera(_delta):
  pass
