extends "../GlitchEnemy.gd"

onready var secretAniPlayer = get_node("SecretAnimationPlayer")
onready var secretBounceAniPlayer = get_node("SecretBounceAnimationPlayer")
onready var crystalsContainer = get_node("Crystals")
onready var crystal1 = get_node("Crystals/HighpriestessCrystal")
onready var noseSprite = get_node("SpriteContainer/InnerSpriteContainer/NoseSprite")
onready var spriteContainer = get_node("SpriteContainer")

var MAX_NUM_HITS = 3
var num_hits = 0
var dreidel_timer = 0
var dreidel_time_limit = 40
var dizzy_timer = 0
var dizzy_time_limit = 30
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
}
var boss_phase = BossPhase.ASLEEP
var asleep_unearth_counter = 0
onready var spawnSound = get_node("Sounds/SpawnSound")

func _ready():
    set_process(true)
    sprite_offset_y = 7.5
    # Wait two frames cuz idk
    yield(TempTimer.idle_frame(self), "timeout")
    yield(TempTimer.idle_frame(self), "timeout")
    crystal1.applyGlitchMaterial(5)

# be careful cuz both the HurtPlayerArea and the InteractArea will both rely on this one function...
func isActive(debug = false):
    return .isActive(debug)

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
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            global.pauseGame = false
            global.shouldRenderAsCinematic = false
            secretAniPlayer.play("idleStand")
            boss_phase = BossPhase.IDLE
            if global.memory["dogu_matryoshka_boss"] == 0:
                global.memory["dogu_matryoshka_boss"] = 1
                musicPlayer.tryToPlay(musicPlayer.bossThemePlayer)
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
        if dreidel_timer >= dreidel_time_limit:
            behavior_walking = false
            dreidel_timer = 0
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("dizzy")
            boss_phase = BossPhase.DIZZY
    elif boss_phase == BossPhase.DIZZY:
        dizzy_timer += (delta*11)
        if dizzy_timer >= dizzy_time_limit:
            dizzy_timer = 0
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("idleStand")
            boss_phase = BossPhase.IDLE
    elif boss_phase == BossPhase.FALL_OVER:
        if not secretAniPlayer.is_playing():
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("stunTwitch")
            boss_phase = BossPhase.STUN_TWITCH
    elif boss_phase == BossPhase.STUN_TWITCH:
        pass

    noseSprite.flip_h = mySprite.flip_h

func getHurt():
    mySprite.visible = true
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("gotHurt")

func getSmacked(broom_origin = Vector3(0, 0, 0), silently = false):
    if is_smacked or boss_phase == BossPhase.DRILL_DREIDEL_SPIN:
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

    if boss_phase == BossPhase.DIZZY:
        boss_phase = BossPhase.FALL_OVER
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        secretAniPlayer.play("fallOver")

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

# @override
func glitchSetSpritesAndCollision():
    spriteContainer.global_transform.origin.y = self.global_transform.origin.y + sprite_offset_y