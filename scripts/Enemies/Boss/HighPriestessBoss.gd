extends Spatial

var weakEyeRes = preload("res://sceneObjects/Enemies/WeakEye.tscn")
var spawnGlitchEffectRes = preload("res://sceneObjects/SpawnGlitchEffect.tscn")
var glitchEnemyRes = preload("res://sceneObjects/Enemies/GlitchEnemy.tscn")
onready var secretAniPlayer = get_node("SecretAnimationPlayer")

var big_spawn_timer = 0
var big_spawn_time_limit = 20
var num_spawns = 0
var num_spawn_limit = 5

var spawn_timer = 0
var spawn_time_limit = 1
var has_animated_attack = false

enum BossPhase {
    IDLE,
    CASTING,
}
var boss_phase = BossPhase.CASTING

var original_pos = null
var target_pos = null


func _ready():
    set_process(true)
    # Wait two frames cuz idk
    yield(TempTimer.idle_frame(self), "timeout")
    yield(TempTimer.idle_frame(self), "timeout")
    original_pos = global_transform.origin
    randomizeTargetPos()

func _process(delta):
    var landings = get_tree().get_nodes_in_group("priestess_landing")
    for landing in landings:
        landing.visible = false

    if target_pos != null:
        moveAbout(delta)

    big_spawn_timer += (delta*11)
    if big_spawn_timer >= big_spawn_time_limit:
        if not has_animated_attack:
            secretAniPlayer.play("windUpCast")
            has_animated_attack = true
        spawn_timer += (delta*11)
        if spawn_timer >= spawn_time_limit:
            spawn_timer = 0
            spawnAttack()
            num_spawns += 1
            if num_spawns >= num_spawn_limit:
                num_spawns = 0
                big_spawn_timer = 0
                has_animated_attack = false

func moveAbout(delta):
    var step = 1
    global_transform.origin = global_transform.origin + (target_pos - global_transform.origin) * (delta*step)
    
    if stepify(target_pos.x, 0.1) == stepify(global_transform.origin.x, 0.1) and \
       stepify(target_pos.y, 0.1) == stepify(global_transform.origin.y, 0.1):
        randomizeTargetPos()

func randomizeTargetPos():
    target_pos = Vector3(
        original_pos.x + rand_range(-3, 3),
        original_pos.y + rand_range(-3, 3),
        original_pos.z
    )

# be a bit more deterministic... ideally, we would
# 1. spawn one on or very near the player
# 2. spawn a weak eye in one of 4 positions
# 3. spawn 3 other glitches in one of like ~8 positions depending on player position?
# 4. spawn 2 other glitches out of reach just for visual flair
func getRandomSpawnPosition():
    var pos = global_transform.origin
    var randX = rand_range(-10, 10)
    var randY = rand_range(-10, 10)
    return Vector3(pos.x + randX, pos.y + randY, pos.z)

func spawnAttack():
    var newGlitchEnemy = glitchEnemyRes.instance()
    newGlitchEnemy.visible = true
    newGlitchEnemy.grav = 0
    newGlitchEnemy.get_node("Sprite3D").frame_delay = 0.2
    newGlitchEnemy.behavior_evolve = true
    newGlitchEnemy.behavior_fizzle_out_after_evolve = true
    level.add_child(newGlitchEnemy)
    newGlitchEnemy.global_transform.origin = getRandomSpawnPosition()
    var newGlitchMaterial = newGlitchEnemy.mySprite.get_material_override().duplicate()
    if newGlitchEnemy.is_in_group("sprite"):
        newGlitchEnemy.mySprite.remove_from_group("sprite")
    if newGlitchMaterial is ShaderMaterial:
        newGlitchMaterial.set_shader_param("target_palette", global.weird_base_palette)
    newGlitchEnemy.mySprite.set_material_override(newGlitchMaterial)

    var newSpawnGlitchEffect = spawnGlitchEffectRes.instance()
    level.add_child(newSpawnGlitchEffect)
    newSpawnGlitchEffect.global_transform.origin = newGlitchEnemy.global_transform.origin


onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var player = null
func getPlayer():
    if level == null:
        level = get_tree().get_root().get_node("Game/Viewport/level")
    if player == null:
        player = level.player
    return player
