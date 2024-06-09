extends Spatial

var weakEyeRes = preload("res://sceneObjects/Enemies/WeakEye.tscn")
var spawnGlitchEffectRes = preload("res://sceneObjects/SpawnGlitchEffect.tscn")
var glitchEnemyRes = preload("res://sceneObjects/Enemies/GlitchEnemy.tscn")
var basicFrogEnemyRes = preload("res://sceneObjects/Enemies/BasicFrogEnemy.tscn")
onready var secretAniPlayer = get_node("SecretAnimationPlayer")
onready var mySprite = get_node("Sprite3D")

var big_spawn_timer = 30
var big_spawn_time_limit = 60
var num_spawns = 0
var num_spawn_limit = 3

var spawn_timer = 0
var spawn_time_limit = 1
var has_animated_attack = false

enum BossPhase {
    IDLE,
    CASTING,
    FROG_PLAGUE_READY,
    FROG_PLAGUE_SPAWNING,
    FROG_PLAGUE_WAITING,
    CRONE_CHASE,
    COMPLETE,
}
var boss_phase = BossPhase.CASTING

var original_pos = null
var target_pos = null

var landingArray = []
var frogArray = []
onready var laughSound = get_node("Sounds/LaughSound")
onready var spawnSound = get_node("Sounds/SpawnSound")
func _ready():
    set_process(true)
    # Wait two frames cuz idk
    yield(TempTimer.idle_frame(self), "timeout")
    yield(TempTimer.idle_frame(self), "timeout")
    original_pos = global_transform.origin
    randomizeTargetPos()

    var landings = get_tree().get_nodes_in_group("priestess_landing")
    for landing in landings:
        landing.visible = false
        landingArray.push_back(landing)

var hp = 3
func getHurt():
    mySprite.visible = true
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("gotHurt")
    num_spawns = 0
    big_spawn_timer = 0
    has_animated_attack = false
    landingArray.shuffle()

    hp -= 1
    if hp == 2:
        num_spawn_limit = len(landingArray) / 2
    elif hp == 1 or hp == 0:
        boss_phase = BossPhase.FROG_PLAGUE_READY
    elif hp == -1:
        num_spawn_limit = len(landingArray)
        boss_phase = BossPhase.CASTING
        big_spawn_timer = 0
    elif hp == -2:
        boss_phase = BossPhase.CRONE_CHASE
    elif hp == -4:
        boss_phase = BossPhase.COMPLETE

func _process(delta):
    if global.pauseGame:
        return

    if target_pos != null and not (secretAniPlayer.assigned_animation == "gotHurt" and secretAniPlayer.is_playing()):
        moveAbout(delta)

    if boss_phase == BossPhase.FROG_PLAGUE_READY:
        if not secretAniPlayer.is_playing():
            mySprite.visible = false
            boss_phase = BossPhase.FROG_PLAGUE_SPAWNING
            spawn_timer = 0
            num_spawns = 0
            num_spawn_limit = 7
            laughSound.play()
    elif boss_phase == BossPhase.FROG_PLAGUE_SPAWNING:
        spawn_timer += (delta*11)
        if spawn_timer >= spawn_time_limit * 4:
            spawn_timer = 0
            num_spawns += 1
            var frog = basicFrogEnemyRes.instance()
            frog.is_infected = true
            frog.on_ground = true
            frog.behavior_jumping = true
            frog.behavior_walking = true
            if randi() % 2 == 0:
                frog.walk_direction.x = 1
            else:
                frog.walk_direction.x = -1
            frog.is_fragile = true
            level.add_child(frog)
            frog.global_transform.origin = getRandomSpawnPosition(3)
            frogArray.push_back(weakref(frog))
            spawnSound.play()
            if num_spawns >= num_spawn_limit:
                num_spawns = 0
                spawn_timer = 0
                boss_phase = BossPhase.FROG_PLAGUE_WAITING
                big_spawn_timer = 20
                frogArray.shuffle()
    elif boss_phase == BossPhase.FROG_PLAGUE_WAITING:
        var weak_enemies = level.get_tree().get_nodes_in_group("weak_enemies")
        if weak_enemies.size() == 0:
            spawnWeakEye()
            landingArray.shuffle()
        else:
            big_spawn_timer += (delta*11)
            if big_spawn_timer >= big_spawn_time_limit:
                big_spawn_timer = 20
                var firstInfectedIndex = 0
                for i in range(len(frogArray)):
                    var frog = frogArray[i].get_ref()
                    if frog != null and isFrogInfected(frog):
                        firstInfectedIndex = i
                        break
                var infectedFrog = frogArray[firstInfectedIndex]
                if infectedFrog.get_ref() != null:
                    var weakEye = weakEyeRes.instance()
                    infectedFrog.get_ref().add_child(weakEye)
                    weakEye.global_transform.origin = infectedFrog.get_ref().global_transform.origin
                    weakEye.global_transform.origin.y += 0.75
                    weakEye.global_transform.origin.z += 0.5
                frogArray.shuffle()
    elif boss_phase == BossPhase.CASTING:
        big_spawn_timer += (delta*11)
        if big_spawn_timer >= big_spawn_time_limit:
            if not has_animated_attack:
                secretAniPlayer.play("windUpCast")
                has_animated_attack = true
            spawn_timer += (delta*11)
            if spawn_timer >= spawn_time_limit:
                spawn_timer = 0
                spawnAttack(num_spawns, false)
                num_spawns += 1
                if num_spawns == 2:
                    spawnAttack(0, true)
                if num_spawns >= num_spawn_limit:
                    spawnWeakEye()
                    num_spawns = 0
                    big_spawn_timer = 0
                    has_animated_attack = false
                    landingArray.shuffle()


    frogCleanup(delta)

var frog_cleanup_timer = 0
var frog_cleanup_time_limit = 3
func frogCleanup(delta):
    if len(frogArray) == 0 or \
       boss_phase == BossPhase.FROG_PLAGUE_READY or \
       boss_phase == BossPhase.FROG_PLAGUE_SPAWNING or \
       boss_phase == BossPhase.FROG_PLAGUE_WAITING:
        return

    frog_cleanup_timer += (delta*11)
    if frog_cleanup_timer >= frog_cleanup_time_limit:
        frog_cleanup_timer = 0
        var frogRef = frogArray.pop_back()
        if frogRef.get_ref() != null:
            frogRef.get_ref().queue_free()
            level.summonSmokeClouds(frogRef.get_ref().global_transform.origin, 1, false, true)

func isFrogInfected(frog):
    return frog.is_infected
    
func moveAbout(delta):
    var step = 1
    global_transform.origin = global_transform.origin + (target_pos - global_transform.origin) * (delta*step)
    
    if stepify(target_pos.x, 0.1) == stepify(global_transform.origin.x, 0.1) and \
       stepify(target_pos.y, 0.1) == stepify(global_transform.origin.y, 0.1):
        randomizeTargetPos()

func randomizeTargetPos():
    target_pos = Vector3(
        original_pos.x + rand_range(-5, 5),
        original_pos.y + rand_range(-5, 5),
        original_pos.z
    )

func spawnWeakEye():
    var weakEye = weakEyeRes.instance()
    level.add_child(weakEye)
    weakEye.global_transform.origin = landingArray[0].global_transform.origin if len(landingArray) > 0 else getRandomSpawnPosition()

# be a bit more deterministic... ideally, we would
# 1. spawn one on or very near the player
# 2. spawn a weak eye in one of 4 positions
# 3. spawn 3 other glitches in one of like ~8 positions depending on player position?
# 4. spawn 2 other glitches out of reach just for visual flair
func getRandomSpawnPosition(theMax = 10):
    var pos = global_transform.origin
    var randX = rand_range(-theMax, theMax)
    var randY = rand_range(-theMax, theMax)
    return Vector3(pos.x + randX, pos.y + randY, pos.z)

func spawnAttack(which_spawn, spawn_on_player):
    var newGlitchEnemy = glitchEnemyRes.instance()
    newGlitchEnemy.visible = true
    newGlitchEnemy.grav = 0
    newGlitchEnemy.get_node("Sprite3D").frame_delay = 0.2
    newGlitchEnemy.behavior_evolve = true
    newGlitchEnemy.behavior_fizzle_out_after_evolve = true
    level.add_child(newGlitchEnemy)
    if spawn_on_player:
        newGlitchEnemy.global_transform.origin = getPlayer().global_transform.origin
    else:
        newGlitchEnemy.global_transform.origin = landingArray[which_spawn].global_transform.origin if which_spawn < len(landingArray) else getRandomSpawnPosition()
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
