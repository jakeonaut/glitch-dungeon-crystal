extends "../GlitchEnemy.gd"


onready var secretAniPlayer = get_node("SecretAnimationPlayer")

onready var cubeCrystal = weakref(get_node("CubeCrystal"))
onready var fakeCrystalContainer = get_node("FakeCrystals")
onready var weakPointContainer = get_node("WeakPointContainer")
onready var weakPointAniPlayer = get_node("WeakPointContainer/WeakPointAnimationPlayer")
onready var weakEyeAniPlayer = get_node("WeakPointContainer/WeakEye/SecretAnimationPlayer")
onready var weakPointTarget = get_node("WeakPointTarget")
onready var tailContainer = get_node("TailContainer")
onready var crystals = get_node("Crystals")
onready var dangleContainer = get_node("DangleContainer")
onready var screamSound = get_node("Sounds/ScreamSound")
onready var chargeSound = get_node("Sounds/ChargeSound")
var basicFrogEnemyRes = preload("res://sceneObjects/Enemies/BasicFrogEnemy.tscn")
var basicFrogEnemies = []
var crystalGeodeRes = preload("res://sceneObjects/CrystalGeode2.tscn")

var num_hits = 0
var MAX_NUM_HITS = 3
var num_granny_hits = 0
var MAX_GRANNY_HITS = 3

enum BossPhase {
    IDLE,
    LYING_IN_WAIT,
    WAKING_UP,
    PREPARING_CHARGE,
    CHARGING,
    CHARGING_BACKWARDS,
    TURNING_LEFT_TO_RIGHT,
    TURNING_RIGHT_TO_LEFT,
    BARFING_SNAILS,
    HIDING_WITH_DUPLICATES,
    EAT_IT,
    STUN_FALL,
    STUN_IDLE,
    HURT,
    DEFEATED,
    GNASH_ATTACK_PREP,
    GNASH_ATTACK_CHARGE,
}
var boss_phase = BossPhase.LYING_IN_WAIT

var original_pos = null
var target_pos = null
var lure_bullet_direction_vector = null
var BULLET_SPEED = 15
var idle_timer = 0
var idle_time_limit = 20
var charging_time_limit = 30
var gnash_charge_time_limit = 15
var crystal_appear_time_limit = 10
var stun_timer = 0
var stun_time_limit = 120
var is_weakpoint_attached = true
var crystalLandings = []
var which_three = []
var gnash_charge_position = null
var how_many_final_charges = 0

onready var spawnSound = get_node("Sounds/SpawnSound")
func _ready():
    if global.memory["anglerShortcut"] == 0:
        global.memory["anglerShortcut"] = 1
    set_process(true)
    is_sprite_flipped = true
    should_collide_floor = false
    should_collide_ceil = false
    should_collide_horizontally = false
    should_collide_fallthrough_area = false
    # Wait two frames cuz idk
    yield(TempTimer.idle_frame(self), "timeout")
    yield(TempTimer.idle_frame(self), "timeout")
    original_pos = global_transform.origin
    randomizeTargetPos()
    crystalLandings = level.get_tree().get_nodes_in_group("crystal_landing")

    behavior_phase_through_walls = true
    walk_speed = 24

    self.remove_child(fakeCrystalContainer)
    level.add_child(fakeCrystalContainer)

var has_already_hidden = false

# @override
func unsmack():
    .unsmack()
    if boss_phase == BossPhase.STUN_FALL:
        grav = 60

func getMyVariable():
    return global.memory["angler_seaman_boss"]

var preyTarget = null
func _process(delta):
    # need to be before global.pauseGame check so we can unpause
    if boss_phase == BossPhase.LYING_IN_WAIT:
        unenemize()
        if cubeCrystal.get_ref() != null and cubeCrystal.get_ref().meshInstance1.visible:
            cubeCrystal.get_ref().meshInstance1.visible = false
            cubeCrystal.get_ref().ok_byebye = true
            startBossFight()
        if global.memory["angler_seaman_boss"] == 1:
            startBossFight()
            cubeCrystal.get_ref().ok_byebye = true
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
            # cubeCrystal.get_ref().applyGlitchMaterial(5)
            if global.memory["angler_seaman_boss"] == 0:
                global.memory["angler_seaman_boss"] = 1
                level.restartMusic()
                level.uiLayer.setDisplayTitle(tr("UI.BossName.1"))
        return
    elif boss_phase == BossPhase.DEFEATED:
        moveToSpecificPosition(delta, Vector3(52.134, -19.847, 0), 1, false)
        idle_timer += (delta*11)
        if idle_timer >= 5:
            idle_timer = 0
            var random_pos = global_transform.origin + Vector3(rand_range(-2, 2), rand_range(-2, 2), 0)
            level.summonSmokeClouds(random_pos, 1, true, true, false)
        # if secretAniPlayer.assigned_animation == "defeated" and not secretAniPlayer.is_playing():
        #     pass
        # self.rotation_degrees.y += delta*22

    if global.pauseGame:
        return

    if boss_phase == BossPhase.IDLE:
        weakPointContainer.vulnerable = false
        if target_pos != null:
            moveAbout(delta)
        idle_timer += (delta*11)
        if idle_timer >= idle_time_limit:
            idle_timer = 0
            boss_phase = BossPhase.PREPARING_CHARGE
    elif boss_phase == BossPhase.BARFING_SNAILS:
        weakPointContainer.vulnerable = false
        moveToSpecificPosition(delta, Vector3(65, level.player.global_transform.origin.y, 0), 1, false)
        if "barfingSnails" in secretAniPlayer.assigned_animation and not secretAniPlayer.is_playing():
            boss_phase = BossPhase.IDLE
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("idle")
            weakPointAniPlayer.stop()
            weakPointAniPlayer.clear_queue()
            weakPointAniPlayer.play("idle")
    elif boss_phase == BossPhase.PREPARING_CHARGE:
        how_many_final_charges = 0
        if secretAniPlayer.assigned_animation != "openUp" and secretAniPlayer.assigned_animation != "openIdle":
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("openUp")
            secretAniPlayer.queue("openIdle")
        # this position is stupid and specific to the level I'm in... oh well
        moveToSpecificPosition(delta, Vector3(65, level.player.global_transform.origin.y, 0), 1.5, false)
        idle_timer += (delta*11)
        if idle_timer >= charging_time_limit:
            idle_timer = 0
            boss_phase = BossPhase.CHARGING
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("charging")
            chargeSound.play()
    elif boss_phase == BossPhase.CHARGING:
        behavior_walking = true
        walk_direction.x = -1
        # this is stupid and specific to the level I'm in... oh well
        if global_transform.origin.x < 28:
            if how_many_final_charges >= num_hits:
                behavior_walking = false
                dir = Vector3(0, 0, 0)
                lv.x = 0
                linear_velocity.x = 0
                hv = Vector3(0, 0, 0)
                boss_phase = BossPhase.STUN_FALL
                level.player.bumpSound.play()
                unenemize()
                secretAniPlayer.stop()
                secretAniPlayer.clear_queue()
                secretAniPlayer.play("stunFall")
                tryToStartWeakPointDetachment()
                getSmacked()
            elif global_transform.origin.x < 14:
                how_many_final_charges += 1
                boss_phase = BossPhase.CHARGING_BACKWARDS    
                self.global_transform.origin.y = level.player.global_transform.origin.y
                self.rotation_degrees.y = 180 # from 0
                tailContainer.translation.z = 6 # from 0
                dangleContainer.translation.z = 6 # from 0
                crystals.translation.z = 2.13 # from -2.13
                mySprite.translation.z = 2 # from -2
                chargeSound.play()
    elif boss_phase == BossPhase.CHARGING_BACKWARDS:
        behavior_walking = true
        walk_direction.x = 1
        if global_transform.origin.x >= 66:
            if how_many_final_charges >= num_hits:
                behavior_walking = false
                dir = Vector3(0, 0, 0)
                lv.x = 0
                linear_velocity.x = 0
                hv = Vector3(0, 0, 0)
                boss_phase = BossPhase.STUN_FALL
                level.player.bumpSound.play()
                unenemize()
                secretAniPlayer.stop()
                secretAniPlayer.clear_queue()
                secretAniPlayer.play("stunFall")
                tryToStartWeakPointDetachment()
                getSmacked()
            elif global_transform.origin.x >= 80:
                how_many_final_charges += 1
                boss_phase = BossPhase.CHARGING
                self.global_transform.origin.y = level.player.global_transform.origin.y
                self.rotation_degrees.y = 0 # from 180
                tailContainer.translation.z = 0 # from 6
                dangleContainer.translation.z = 0 # from 6
                crystals.translation.z = -2.13 # from 2.13
                mySprite.translation.z = -2 # from 2
                chargeSound.play()
    elif boss_phase == BossPhase.HIDING_WITH_DUPLICATES:
        has_already_hidden = true
        behavior_walking = false
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
                    newFakeCrystal.fakify()
                    fakeCrystalContainer.add_child(newFakeCrystal)
                    newFakeCrystal.global_transform.origin = crystalLanding.global_transform.origin

        if cubeCrystal.get_ref() != null and cubeCrystal.get_ref().meshInstance1.visible:
            cubeCrystal.get_ref().meshInstance1.visible = false
            boss_phase = BossPhase.IDLE
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("fadeFromBlack")
            secretAniPlayer.queue("idle")
            behavior_walking = false
            dir = Vector3(0, 0, 0)
            lv.x = 0
            linear_velocity.x = 0
            hv = Vector3(0, 0, 0)

            var fakeCrystals = fakeCrystalContainer.get_children()
            for fakeCrystal in fakeCrystals:
                fakeCrystalContainer.remove_child(fakeCrystal)
                fakeCrystal.queue_free()
    elif boss_phase == BossPhase.GNASH_ATTACK_PREP:
        idle_timer += (delta*11)
        if idle_timer >= gnash_charge_time_limit:
            idle_timer = 0
            boss_phase = BossPhase.GNASH_ATTACK_CHARGE
            gnash_charge_position = level.player.global_transform.origin

        if player.global_transform.origin.x > self.global_transform.origin.x + 2 and self.rotation_degrees.y < 90:
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("turnLeftToRight")
            secretAniPlayer.queue("gnashAttack")
        elif player.global_transform.origin.x < self.global_transform.origin.x - 2 and self.rotation_degrees.y > 90:
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("turnRightToLeft")
            secretAniPlayer.queue("gnashAttack")
    elif boss_phase == BossPhase.GNASH_ATTACK_CHARGE:
        if not ("turn" in secretAniPlayer.assigned_animation):
            if moveToSpecificPosition(delta, gnash_charge_position, 2):
                boss_phase = BossPhase.GNASH_ATTACK_PREP

    elif boss_phase == BossPhase.EAT_IT:
        behavior_walking = false
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
        behavior_walking = false
        on_ground = false
        if global_transform.origin.y <= -30:
            grav = 0
            linear_velocity.y = 0
            lv.y = 0
            vv = 0
            global_transform.origin.y = -30
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
        has_already_hidden = false
        moveToSpecificPosition(delta, Vector3(52.134, -19.847, 0), 1, false)
        if not secretAniPlayer.is_playing():
            self.rotation_degrees.y = 0 # from 180
            tailContainer.translation.z = 0 # from 6
            dangleContainer.translation.z = 0 # from 6
            crystals.translation.z = -2.13 # from 2.13
            mySprite.translation.z = -2 # from 2
            if num_hits <= MAX_NUM_HITS:
                boss_phase = BossPhase.BARFING_SNAILS
                secretAniPlayer.stop()
                secretAniPlayer.clear_queue()
                secretAniPlayer.play("barfingSnails")
                weakPointAniPlayer.stop()
                weakPointAniPlayer.clear_queue()
                weakPointAniPlayer.play("idle")
            elif num_hits == 1:
                boss_phase = BossPhase.PREPARING_CHARGE
            else:
                boss_phase = BossPhase.IDLE
                secretAniPlayer.stop()
                secretAniPlayer.clear_queue()
                secretAniPlayer.play("idle")
                weakPointAniPlayer.stop()
                weakPointAniPlayer.clear_queue()
                weakPointAniPlayer.play("idle")
    
    if cubeCrystal.get_ref() != null:
        cubeCrystal.get_ref().meshInstance1.visible = false


# @override
func setSpriteFlipH(_flip_h):
    pass

func startBossFight():
    if boss_phase != BossPhase.LYING_IN_WAIT:
        return false
    level.player.aniPlayer.stop()
    level.player.aniPlayer.clear_queue()
    level.player.aniPlayer.queue("fall")
    if level.player.summonedBroom:
        level.player.broomStop()

    musicPlayer.stopAll()
    global.pauseGame = true
    global.shouldRenderAsCinematic = true
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("fadeFromBlack")
    secretAniPlayer.queue("openAndScream")
    boss_phase = BossPhase.WAKING_UP
    level.gameCamera.initial_size = 30
    level.gameCamera.zoomed_size = 30

func barfRandomSnail():
    if num_hits <= basicFrogEnemies.size():
        return

    var basicFrogEnemy = basicFrogEnemyRes.instance()
    basicFrogEnemy.is_infected = true
    level.add_child(basicFrogEnemy)
    yield(TempTimer.idle_frame(self), "timeout")
    # glitchHermitCrabManager.scale = Vector3(1.5, 1.5, 1.5)
    basicFrogEnemy.global_transform.origin = self.global_transform.origin + Vector3(-3.333, 0.265, 0)
    basicFrogEnemies.push_back(weakref(basicFrogEnemy))

func teleportToPrey():
    if preyTarget != null and preyTarget.get_ref() != null:
        var prey = preyTarget.get_ref()
        global_transform.origin = prey.global_transform.origin + Vector3(2, -0.361, 0)

func gotcha():
    if preyTarget != null and preyTarget.get_ref() != null:
        var prey = preyTarget.get_ref()
        if prey == level.player:
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

    # if boss_phase == BossPhase.STUN_FALL or boss_phase == BossPhase.STUN_IDLE:
    time_influence = 35
    y_div = 5
    normal_offset = 0.5
    return .getSmacked(broom_origin, silently)

    # boss_phase = BossPhase.EAT_IT
    # secretAniPlayer.stop()
    # secretAniPlayer.clear_queue()
    # lure_bullet_direction_vector = null
    # preyTarget = weakref(level.player)
    # secretAniPlayer.play("chompDown")
    # weakPointAniPlayer.stop()
    # weakPointAniPlayer.clear_queue()
    # weakPointAniPlayer.play("chompDown")
    # return false
    

func tryToStartWeakPointDetachment():
    # if num_hits <= 0:
    if weakPointAniPlayer.assigned_animation != "ouchies" and weakPointAniPlayer.assigned_animation != "stunIdleAttached":
        weakPointAniPlayer.stop()
        weakPointAniPlayer.clear_queue()
        weakPointAniPlayer.play("ouchies")
        weakPointAniPlayer.queue("stunIdleAttached")
        weakEyeAniPlayer.play("blinkOpen")
    return
    # if is_weakpoint_attached and weakPointAniPlayer.assigned_animation != "detachSelf":
    #     weakPointAniPlayer.stop()
    #     weakPointAniPlayer.clear_queue()
    #     weakPointAniPlayer.play("detachSelf")
    #     weakPointAniPlayer.queue("stunIdle")

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

func defeatMe():
    idle_timer = 0
    unenemize()
    boss_phase = BossPhase.DEFEATED
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("ouchies")
    secretAniPlayer.queue("defeated")
    global.pauseGame = true
    global.shouldRenderAsCinematic = true
    Steam.set_achievement("ANGLER_BOSS")

func okayImDead():
    if global.memory["angler_seaman_boss"] < 2:
        global.memory["angler_seaman_boss"] = 2
        musicPlayer.stopAll()
        musicPlayer.playDefeatBossJingle()
        level.summonSmokeClouds(level.door.global_transform.origin, 2, true, true)
    for basicFrogEnemyRef in basicFrogEnemies:
        if basicFrogEnemyRef.get_ref():
            basicFrogEnemyRef.get_ref().getSmacked()
    global.pauseGame = false
    global.shouldRenderAsCinematic = false

    var newRealCrystal = crystalGeodeRes.instance()
    level.add_child(newRealCrystal)
    newRealCrystal.global_transform.origin = Vector3(49, -23, 0)
    level.summonSmokeClouds(newRealCrystal.global_transform.origin, 3, true, true, false)
    level.door.visible = true
    queue_free()

# @override
func actuallyDieToOffscreenCamera(_delta):
  pass
