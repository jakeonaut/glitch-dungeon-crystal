extends Spatial

var spawnGlitchEffectRes = preload("res://sceneObjects/SpawnGlitchEffect.tscn")
var glitchEnemyRes = preload("res://sceneObjects/Enemies/GlitchEnemy.tscn")
var basicFrogEnemyRes = preload("res://sceneObjects/Enemies/BasicFrogEnemy.tscn")
var savePointRes = preload("res://sceneObjects/SavePoint.tscn")

onready var secretAniPlayer = get_node("SecretAnimationPlayer")
onready var mySprite = get_node("Sprite3D")
onready var crystalsContainer = get_node("Crystals")
onready var crystal1 = get_node("Crystals/HighpriestessCrystal")

onready var lureContainer = get_node("LureContainer")
onready var lureFreeRange = get_node("LureContainer/FreeRange")
onready var lureAniPlayer = get_node("LureContainer/FreeRange/AnimationPlayer")

var MAX_NUM_HITS = 3

enum BossPhase {
    IDLE,
    WINDUP_CAST,
    CAST_LURE,
}
var boss_phase = BossPhase.IDLE

var original_pos = null
var target_pos = null
var bullet_direction_vector = null
var BULLET_SPEED = 15
var cast_timer = 0
var cast_time_limit = 30

onready var spawnSound = get_node("Sounds/SpawnSound")
func _ready():
    set_process(true)
    # Wait two frames cuz idk
    yield(TempTimer.idle_frame(self), "timeout")
    yield(TempTimer.idle_frame(self), "timeout")
    original_pos = global_transform.origin
    randomizeTargetPos()

    crystal1.applyGlitchMaterial(5)

var num_hits = 0
func getHurt():
    mySprite.visible = true
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("gotHurt")

func _process(delta):
    if global.pauseGame:
        return

    if boss_phase == BossPhase.IDLE:
        if target_pos != null and not (secretAniPlayer.assigned_animation == "gotHurt" and secretAniPlayer.is_playing()):
            moveAbout(delta)
        cast_timer += (delta*11)
        if cast_timer >= cast_time_limit:
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
        lureFreeRange.global_transform.origin += bullet_direction_vector * delta

func doLureCast():
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("idle")
    boss_phase = BossPhase.CAST_LURE
    if lureFreeRange.get_parent() == lureContainer:
        var temp_pos = lureFreeRange.global_transform.origin
        lureContainer.remove_child(lureFreeRange)
        level.add_child(lureFreeRange)
        lureFreeRange.global_transform.origin = temp_pos
    if bullet_direction_vector == null:
        var player_pos = level.player.global_transform.origin
        var lure_pos = lureContainer.global_transform.origin
        bullet_direction_vector = Vector3(
            player_pos.x - lure_pos.x,
            player_pos.y - lure_pos.y,
            0
        ).normalized() * BULLET_SPEED

    
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

func randomizeTargetPos():
    target_pos = Vector3(
        original_pos.x + rand_range(-5, 5),
        original_pos.y + rand_range(-3, 5),
        original_pos.z
    )

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var player = null
func getPlayer():
    if level == null:
        level = get_tree().get_root().get_node("Game/Viewport/level")
    if player == null:
        player = level.player
    return player
