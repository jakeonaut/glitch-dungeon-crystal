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
onready var fishLureSprite = get_node("LureContainer/FreeRange/FishLureSprite")
onready var reelStopArea = get_node("LureContainer/ReelStopArea")

var MAX_NUM_HITS = 3

enum BossPhase {
    IDLE,
    WINDUP_CAST,
    CAST_LURE,
    REEL_IT_IN,
    EAT_IT,
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
        lureFreeRange.global_transform.origin += bullet_direction_vector * delta
        lureBulletTryDieToSolids()
        if lureFreeRange.hooked:
            boss_phase = BossPhase.REEL_IT_IN
    elif boss_phase == BossPhase.REEL_IT_IN:
        if lureFreeRange.hooked:
            fishLureSprite.scale = Vector3(1, 1, 1)
        else:
            fishLureSprite.scale = Vector3(2, 2, 1)

        var pos = reelStopArea.global_transform.origin
        var lure_pos = lureFreeRange.global_transform.origin
        bullet_direction_vector = Vector3(
            pos.x - lure_pos.x,
            pos.y - lure_pos.y,
            0
        ).normalized() * (BULLET_SPEED / 2)
        lureFreeRange.global_transform.origin += bullet_direction_vector * delta

        if lureFreeRange.hookInteractionArea.overlaps_area(reelStopArea):
            boss_phase = BossPhase.EAT_IT
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("chompDown")
            bullet_direction_vector = null
            if lureFreeRange.get_parent() == level:
                level.remove_child(lureFreeRange)
                lureContainer.add_child(lureFreeRange)
                lureFreeRange.global_transform.origin = lureContainer.global_transform.origin
                fishLureSprite.scale = Vector3(1, 1, 1)
    elif boss_phase == BossPhase.EAT_IT:
        if secretAniPlayer.assigned_animation == "chompDown" and not secretAniPlayer.is_playing():
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("idle")
            boss_phase = BossPhase.IDLE

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
    var player_pos = level.player.global_transform.origin
    var lure_pos = lureContainer.global_transform.origin
    bullet_direction_vector = Vector3(
        player_pos.x - lure_pos.x,
        player_pos.y - lure_pos.y,
        0
    ).normalized() * BULLET_SPEED

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

var levelTiles = null
func getLevelTiles():
  if level == null:
    level = get_tree().get_root().get_node("Game/Viewport/level")
  if levelTiles == null:
    levelTiles = level.levelTiles
  return levelTiles
